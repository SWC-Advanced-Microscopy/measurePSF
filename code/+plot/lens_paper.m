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
    %
    %
    % Rob Campbell - SWC 2022


    if nargin<2
        n=1;
    end

    [inputPSFstack,metadata] = mpsf_tools.scanImage_stackLoad(fname);
    micsPerPixelXY = metadata.micsPerPixelXY;


    % Make a new figure or return a plot handle as appropriate
    fig = mpsf_tools.returnFigureHandleForFile([fname,mfilename]);

    im_mu = mean(inputPSFstack,3);
    im_var = var(inputPSFstack,[],3);


    subplot(2,2,1)

    imagesc(im_mu)
    axis equal tight
    colormap gray

    colorbar

    mpsf_tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Mean lens paper image')


    subplot(2,2,2)
    log_im = im_mu;
    log_im(log_im<1)=1;
    imagesc(log(log_im))
    axis equal tight
    colormap gray

    colorbar

    mpsf_tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Log mean lens paper image')



    subplot(2,2,3)
    imagesc(medfilt2(im_var,[3,3]))
    axis equal tight
    colormap gray

    colorbar

    mpsf_tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Variance of lens paper image')


    subplot(2,2,4)
    x = im_mu(1:n:end);
    y = im_var(1:n:end);
    if n>1
        fprintf('Keeping 1 data point in %d for the fit. Total n=%d\n',...
         n, length(x));
    end

    plot(x,y,'.k')

    H=mpsf_tools.addFitLine;

    if n==1
        title(sprintf('Gain %d',round(H.b(2))))
    else
        title(sprintf('Gain %d (kept 1 in %d points)', ...
            round(H.b(2)), n))
    end

    xlabel('Mean')
    ylabel('Variance')



    % Optionally return key parameters as a structure
    if nargout>0
        out.laser_power_in_mw = mpsf_report.laser_power_from_fname(fname);
        out.laser_wavelength_in_nm = mpsf_report.laser_wavelength_from_fname(fname);

        h=sibridge.readTifHeader(fname);
        out.PMT_gain_in_V = h.gains(h.channelSave);
        out.input_range = h.channelsInputRanges{h.channelSave};
        out.PMT_name = h.names{h.channelSave};

        varargout{1} = out;
    end
