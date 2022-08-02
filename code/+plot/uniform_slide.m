function uniform_slide(fname,overlayZoom)
    % Make nice plots of the uniform slide data to explore illumination
    %
    % plot.uniform_slide(fname,overlayZoom)



    if nargin<2
        overlayZoom = [1.2,2,4];
    end


    [inputPSFstack,metadata] = mpsf_tools.scanImage_stackLoad(fname);
    micsPerPixelZ = metadata.stackZStepSize;
    micsPerPixelXY = metadata.micsPerPixelXY;


    % Make a new figure or return a plot handle as appropriate
    fig = mpsf_tools.returnFigureHandleForFile([fname,mfilename]);

    subplot(1,2,1)
    plotData = mean(inputPSFstack,3);

    imagesc(plotData)
    axis equal tight
    colormap gray


    mpsf_tools.add_scale_axis_tick_labels(gca,micsPerPixelXY)
    grid on

    hold on

    contour(medfilt2(plotData,[7,7]),8,'Color','w')

    % Add diagonal lines which we will use later to associate with the next plot
    plot([1,size(plotData,1)], [1,size(plotData,2)], '-r', 'linewidth',2)
    plot([1,size(plotData,1)], [size(plotData,2),1], '-c', 'linewidth',2)

    % Diagnostic/extra information feature: show boxes indicating the FOV
    % at different zooms.
    if ~isempty(overlayZoom)

        zoom_cols = parula(length(overlayZoom));

        for ii=1:length(overlayZoom)
            L=length(inputPSFstack);
            newSize = L/overlayZoom(ii);
            offset = (L-newSize)/2;
            r(ii) = rectangle('Position', [offset,offset,newSize,newSize], ...
                                'EdgeColor', zoom_cols(ii,:));
            text_zoom(ii) = text(offset+1,offset+3, ...
                            sprintf('Zoom %0.1f', overlayZoom(ii)), ...
                            'Color', zoom_cols(ii,:));
        end

    end

    hold off



    % Plot intensity along the red/cyan diagonals
    subplot(1,2,2)

    diagIm = medfilt2(plotData,[7,7]);
    diagIm = diagIm/max(diagIm(:));

    f_diag = eye(length(plotData));


    f = find(f_diag);
    plot(diagIm(f),'-r','linewidth',2)

    hold on

    f = find(rot90(f_diag));
    plot(diagIm(f),'-c','linewidth',2)

    xlim([1,length(f)])
    ylim([min(diagIm(f)), max(diagIm(f))*1.05])
    xticks = [1,length(f)/2,length(f)];
    set(gca,'Xtick',xticks,'XTickLabel',round([0,xticks(2:end)]*micsPerPixelXY))
    grid on


    % Overlay lines corresponding with the zooms
    if ~isempty(overlayZoom)
        L = length(f);
        for ii=1:length(overlayZoom)
            newSize = L/overlayZoom(ii);
            offset = (L-newSize)/2;
            plot([offset,offset],ylim,'Color',zoom_cols(ii,:))
            plot([L-offset,L-offset],ylim,'Color',zoom_cols(ii,:))
        end
    end

    set(gca,'Color',[1,1,1]*0.5)
