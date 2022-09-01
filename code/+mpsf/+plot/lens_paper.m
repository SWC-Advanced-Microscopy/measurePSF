function varargout = lens_paper(fname,n)
    % Use lens paper to estimate gain
    %
    % plot.lens_paper(fname,n)
    %
    % Purpose
    % Uses the lens paper image series to estimate gain.
    %
    % Inputs
    % fname - relative or absolute path to tif containing the data
    % n - optionally keep 1 in n data for the fit. Useful because the PDF
    %     report generates slowly with thousands of data points being
    %     plotted. OPTIONAL, 1 by default.
    %
    %
    % Outputs
    % params - optionally return key imaging parameters as a structure
    % legendText - optionally return a text string describing the graph
    % imData - structure containing data used to plot
    %
    % Rob Campbell - SWC 2022



    % TODO -- add or do the following 
    % Show example single frame
    % histogram of mean intensity for the whole stack. Standardise somehow to allow comparison over session and scopes

    if nargin<2
        n=1;
    end

    [inputPSFstack,metadata] = mpsf.tools.scanImage_stackLoad(fname);
    micsPerPixelXY = metadata.micsPerPixelXY;


    % Make a new figure or return a plot handle as appropriate
    fig = mpsf.tools.returnFigureHandleForFile([fname,mfilename]);

    im_mu = mean(inputPSFstack,3);
    im_var = var(inputPSFstack,[],3);

    %remove data points with really large residuals
    std_thresh=8;
    [~,robust_stats]=robustfit(im_mu(:),im_var(:));
    f = find(robust_stats.resid > std(robust_stats.resid*std_thresh));
    im_var(f) = median(im_var(:));
    im_mu(f) = median(im_mu(:));
    fprintf('Removed %d data points with residuals greater than %d SDs\n', length(f), std_thresh)

    subplot(4,4,[1,2,5,6])

    imagesc(im_mu)
    axis equal tight
    colormap gray
    cMax = getColorScaleLim(im_mu,0.005);
    caxis([0,cMax])
    colorbar

    mpsf.tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Mean lens paper image')


    subplot(4,4,[3,4,7,8])
    imagesc(inputPSFstack(:,:,1))
    axis equal tight
    colormap gray
    cMax = getColorScaleLim(im_mu,0.001);
    caxis([0,cMax])
    colorbar

    mpsf.tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Single frame')


    subplot(4,4,[9,10,13,14])
    x = im_mu(1:n:end);
    y = im_var(1:n:end);
    if n>1
        fprintf('Keeping 1 data point in %d for the fit. Total n=%d\n',...
         n, length(x));
    end

    plot(x,y,'.k')

    H=mpsf.tools.addFitLine;
    system_gain = H.b(2);

    if n==1
        title(sprintf('Gain %d',round(system_gain)))
    else
        title(sprintf('Gain %d (kept 1 in %d points)', ...
            round(system_gain), n))
    end

    xlabel('Mean')
    ylabel('Variance')

    % Do not allow negative numbers in axes as these shouldn't really exist and sometimes the scale
    % is really negative for no good reason.
    ax = gca;
    ax.YLim(1)=0;
    ax.XLim(1)=0;


    subplot(4,4,[11,12])
    hist(im_mu(:),1000)
    ax = gca;
    set(ax.XAxis,'Scale','Log')
    xlabel('Log mean pixel intensity')
    ylabel('#')


    subplot(4,4,[15,16])
    hist(im_mu(:)/system_gain,1000)
    ax = gca;
    set(ax.XAxis,'Scale','Log')
    xlabel('Log mean pixel intensity/gain')
    ylabel('#')


    % Optionally return key parameters as a structure
    if nargout>0
        out.laser_power_in_mw = mpsf.report.laser_power_from_fname(fname);
        out.laser_wavelength_in_nm = mpsf.report.laser_wavelength_from_fname(fname);

        h=sibridge.readTifHeader(fname);
        out.PMT_gain_in_V = h.gains(h.channelSave);
        out.input_range = h.channelsInputRanges{h.channelSave};
        out.PMT_name = h.names{h.channelSave};
        out.frames_per_second = h.scanFrameRate;
        out.image_size = size(im_mu);


        varargout{1} = out;
    end

    if nargout>1
        [~,main_fname,ext] = fileparts(fname);
        txt = sprintf(['%s\nLens paper imaged at %d mW at %d nm. ', ...
            'Using %s at %dV. Input range %d/%d V.'...
            ], ...
            [main_fname,ext], ...
            out.laser_power_in_mw, ...
            out.laser_wavelength_in_nm, ...
            out.PMT_name, ...
            out.PMT_gain_in_V, ...
            out.input_range);
        varargout{2} = txt;
    end

    if nargout>2
        clear out
        out.im_mu = im_mu;
        out.im_var = im_var;
        out.inputPSFstack = inputPSFstack;
        varargout{3} = out;
    end



function colorScaleLim = getColorScaleLim(im,clip_prop)
    % return the maximum color value to plot such that we are not clipping
    % "prop" proportion of the values. e.g. prop of about 0.9 should work.

    if nargin<2
        clip_prop = 0.01;
    end

    sortedVals = sort(im(:),'descend');
    f = round(length(sortedVals)*clip_prop);
    colorScaleLim = sortedVals(f);


