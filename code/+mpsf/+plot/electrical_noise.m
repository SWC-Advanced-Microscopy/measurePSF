function electrical_noise(fname_elec, fname_dark)
    % Electrical noise plots
    %
    % mpsf.plot.electrical_noise(fname)
    %
    % Purpose
    % Plots of electrical noise for each channel with PMTs off and dark
    % noise with PMTs on
    % If there is significant electrical noise, the distributions will likely look non-Gaussian.
    % e.g. They may look like like the sum of two Gaussians with different SDs or they
    % may appear non-symmetric.
    %
    %
    % Rob Campbell - SWC
    % Updated by Isabell Whiteley - SWC 2025


    
    [imstack_elec,metadata] = mpsf.tools.scanImage_stackLoad(fname_elec);
    if isempty(imstack_elec)
        return 
    end

    [imstack_dark,metadata] = mpsf.tools.scanImage_stackLoad(fname_dark);
    if isempty(imstack_dark)
        return 
    end

    % Make a new figure or return a plot handle as appropriate
    fig = mpsf.tools.returnFigureHandleForFile([fname_elec,mfilename]);


    for ii=1:size(imstack_elec,3)
        subplot(2,2,ii)
        t_im_elec = single(imstack_elec(:,:,ii));
        [n,x] = hist(t_im_elec(:),100);
        a=area(x,n);

        a.EdgeColor=[0,0,0.75];
        a.FaceColor=[0.5,0.5,1];
        a.LineWidth=2;
        hold on
        
        t_im_dark = single(imstack_dark(:,:,ii));
        [m,x1] = hist(t_im_dark(:),100);
        b=area(x1,m);

        b.EdgeColor=[0.75,0,0];
        % b.FaceColor=[1,0.5,0.5];
        b.FaceColor='none';
        b.LineWidth=2;


        xlim([min(imstack_elec(:)), max(imstack_elec(:))])
        title(sprintf('Channel %d SD=%0.2f', ii, std(t_im_dark(:))))
        grid on
        hold off
    end
