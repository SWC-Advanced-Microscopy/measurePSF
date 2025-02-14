function varargout = lens_paper(fname,aveBy)
    % Display lens paper images
    %
    % plot.lens_paper(fname)
    %
    % Purpose
    % Display lens paper images. These are used for qualitative comparison only.
    %
    % Inputs
    % fname - relative or absolute path to tiff containing the data
    % aveBy - 1 by default. If >1 average by this much to simulate a slower scanner.
    %
    %
    % Outputs
    % params - optionally return key imaging parameters as a structure
    % txt - legend text for report
    %
    % Rob Campbell, SWC AMF, initial commit 2022



    if nargin<2
        aveBy = 1;
    end

    [imstack,metadata] = mpqc.tools.scanImage_stackLoad(fname);
    if isempty(imstack)
        return
    end

    micsPerPixelXY = metadata.micsPerPixelXY;


    %try averaging to simulate a slower scanner
    if aveBy>1
        n=floor(size(imstack,3)/aveBy);
        t=ones(size(imstack,1),size(imstack,2),n);
        ind = 1;
        for ii = 1:aveBy:size(imstack,3)-aveBy+1
            t(:,:,ind) = mean(imstack(:,:,ii:ii+aveBy-1),3);
            ind = ind+1;
        end

        imstack=t;
    end



    % Make a new figure or return a plot handle as appropriate
    fig = mpqc.tools.returnFigureHandleForFile([fname,mfilename]);

    im_mu = mean(imstack,3);


    subplot(2,2,1)

    imagesc(im_mu)
    axis equal tight
    colormap gray
    cMax = getColorScaleLim(im_mu,0.005);
    caxis([0,cMax])
    colorbar

    mpqc.tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Mean lens paper image')


    subplot(2,2,2)
    imagesc(imstack(:,:,1))
    axis equal tight
    colormap gray
    cMax = getColorScaleLim(im_mu,0.001);
    caxis([0,cMax])
    colorbar

    mpqc.tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Single frame')



    subplot(2,2,3:4)
    hist(im_mu(:),1000)
    ax = gca;
    set(ax.XAxis,'Scale','Log')
    xlabel('Log mean pixel intensity')
    ylabel('#')


    % Optionally return key parameters as a structure
    if nargout>0
        out.laser_power_in_mw = mpqc.report.laser_power_from_fname(fname);
        out.laser_wavelength_in_nm = mpqc.report.laser_wavelength_from_fname(fname);

        h=sibridge.readTifHeader(fname);
        out.PMT_gain_in_V = h.gains(h.channelSave);
        out.input_range = h.channelsInputRanges{h.channelSave};
        out.PMT_name = h.names{h.channelSave};
        out.image_size = size(im_mu);
        out.averagFrames = aveBy;
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

        varargout{2} = txt;
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
