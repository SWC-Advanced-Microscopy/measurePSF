function electrical_noise(fname)
    % Electrical noise plots
    %
    % plot.electrical_noise(fname)
    %
    % Purpose
    % Plots of electrical noise for each channel with PMTs off



    [imstack,metadata] = mpsf.tools.scanImage_stackLoad(fname);
    if isempty(imstack)
        return 
    end

    % Make a new figure or return a plot handle as appropriate
    fig = mpsf.tools.returnFigureHandleForFile([fname,mfilename]);


    for ii=1:size(imstack,3)
        subplot(2,2,ii)
        t_im = single(imstack(:,:,ii));
        [n,x] = hist(t_im(:),100);
        a=area(x,n);

        a.EdgeColor=[0,0,0.75];
        a.FaceColor=[0.5,0.5,1];
        a.LineWidth=2;

        xlim([min(imstack(:)), max(imstack(:))])
        title(sprintf('Channel %d', ii))
    end
