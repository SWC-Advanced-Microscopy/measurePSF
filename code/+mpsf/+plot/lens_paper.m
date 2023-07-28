function varargout = lens_paper(fname,n,aveBy)
    % Use lens paper to estimate gain
    %
    % plot.lens_paper(fname,n,aveBy)
    %
    % Purpose
    % Uses the lens paper image series to estimate gain.
    %
    % Inputs
    % fname - relative or absolute path to tif containing the data
    % n - optionally keep 1 in n data for the fit. Useful because the PDF
    %     report generates slowly with thousands of data points being
    %     plotted. OPTIONAL, 1 by default.
    % aveBy - how many adjacent frames to average before calculating.
    %        1 (no averaging) by default. Used to simulate lower frame rates.
    %        Note: you should find gain scales with 1/aveBy if the dataset is good.
    %
    %
    % Outputs
    % params - optionally return key imaging parameters as a structure
    % legendText - optionally return a text string describing the graph
    % imData - structure containing data used to plot and gain.
    %
    % Rob Campbell - SWC 2022



    % TODO -- add or do the following 
    % Show example single frame
    % histogram of mean intensity for the whole stack. Standardise somehow to allow comparison over session and scopes

    if nargin<2 || isempty(n)
        n = 1;
    end

    if nargin<3 || isempty(aveBy)
        aveBy = 1;
    end


    [imstack,metadata] = mpsf.tools.scanImage_stackLoad(fname);
    if isempty(imstack)
        return 
    end

    micsPerPixelXY = metadata.micsPerPixelXY;


    %try averaging to simulate a slower scanner
    if aveBy>1
        n=floor(size(imstack,3)/aveBy);
        t=ones(size(imstack,1),size(imstack,2),n);
        ind=1;
        for ii=1:aveBy:size(imstack,3)-aveBy+1
            t(:,:,ind) = mean(imstack(:,:,ii:ii+aveBy-1),3);
            ind=ind+1;
        end

        imstack=t;
    end



    % Make a new figure or return a plot handle as appropriate
    fig = mpsf.tools.returnFigureHandleForFile([fname,mfilename]);

    im_mu = mean(imstack,3);
    im_var = var(imstack,[],3);

    %remove data points with really large residuals
    std_thresh = 10;
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
    imagesc(imstack(:,:,1))
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
    system_gain_at_1us = system_gain / (1E-6/metadata.scanPixelTimeMean);
    title(sprintf('Gain %d (estimated gain at 1 %ss: %d)',round(system_gain), char(181), round(system_gain_at_1us) ))


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
        out.frames_per_second_original = h.scanFrameRate;
        out.frames_per_second_analyzed = h.scanFrameRate/aveBy;
        out.image_size = size(im_mu);


        varargout{1} = out;
    end

    if nargout>1
        [~,main_fname,ext] = fileparts(fname);
        txt = sprintf(['%s\nLens paper imaged at %d mW at %d nm. ', ...
            'Using %s at %dV. Input range %d/%d V. Acquired at %d x %d at %d FPS. '...
            ], ...
            [main_fname,ext], ...
            out.laser_power_in_mw, ...
            out.laser_wavelength_in_nm, ...
            out.PMT_name, ...
            out.PMT_gain_in_V, ...
            out.input_range, ...
            metadata.pixelsPerLine, ...
            metadata.linesPerFrame, ...
            round(metadata.scanFrameRate) );

        if aveBy>1
            txt = [txt, ...
            sprintf('Averaged by %d frames to yield %d FPS\n ', ...
                    aveBy, round(metadata.scanFrameRate/2))];
        end

        txt = [txt,'"Gain" refers to the approximate number of DAQ values generated by a single ', ...
                    'photo-event assuming the there is single Poisson process generating the signals. ', ...
                    'The estimated gain at 1', char(181), 's attempts to correct for different ', ...
                    'dwell time between systems.']
        varargout{2} = txt;
    end

    if nargout>2
        clear out
        out.im_mu = im_mu;
        out.im_var = im_var;
        out.imstack = imstack;
        out.aveBy = aveBy;
        out.system_gain = system_gain;
        out.effective_frame_rate = metadata.scanFrameRate/aveBy;
        out.effective_frame_period = 1/out.effective_frame_rate;
        out.effective_scan_pixel_time_us = 1E6 * metadata.scanPixelTimeMean * aveBy;
        out.system_gain_at_1us = system_gain_at_1us;
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


