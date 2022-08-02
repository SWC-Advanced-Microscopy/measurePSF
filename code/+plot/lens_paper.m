function lens_paper(fname)
    % Use lens paper to estimate gain
    %
    % plot.lens_paper(fname)
    %
    % Purpose
    % Uses the lens paper image series to estimate gain



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


    subplot(2,2,3)
    imagesc(medfilt2(im_var,[3,3]))
    axis equal tight
    colormap gray

    colorbar

    mpsf_tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    title('Variance of lens paper image')


    subplot(2,2,4)
    plot(im_mu(:),im_var(:),'.k')
    H=mpsf_tools.addFitLine()
    title(sprintf('Gain %d',round(H.b(2))))

    xlabel('Mean')
    ylabel('Variance')
