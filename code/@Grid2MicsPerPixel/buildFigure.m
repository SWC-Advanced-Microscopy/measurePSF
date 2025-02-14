function buildFigure(obj)
    % Construct and populate the Grid2MicsPerPixel figure window.
    %
    % function Grid2MicsPerPixel.buildFigure(obj)
    %
    % Purpose
    % Builds figures and calculates all statistics
    %
    %
    % Rob Campbell, Basel Biozentrum, 2016


    % TODO: For modularity we might want to move the calculations to a separate function

    if isempty(obj.gridIm)
        fprintf('Grid2MicsPerPixel.buildFigure not running: obj.gridIm is empty\n')
        return
    end


    % The original image
    subplot(2,2,1)
    imagesc(medfilt2(obj.origImage,obj.medFiltSize))
    colormap gray
    origImageSize = size(obj.origImage);
    if obj.cropProp>0
        origTitle=title(sprintf('%d x %d (before cropping)', origImageSize));
    else
        origTitle=title(sprintf('%d x %d', origImageSize));
    end
    axis equal tight

    xlabel('pixels')
    ylabel('pixels')

    % Set the axis color scale: clip the top values
    c = caxis;
    caxis([c(1),c(2)*0.7])


    % The rotated image with the overlaid grid
    obj.hRotatedAx = subplot(2,2,2);

    imagesc(obj.gridIm) %gridIm is the rotated, filtered and offset-subtracted version
    title(sprintf('Corrected tilt by %0.2f degrees',obj.imRotatedAngle))
    axis equal tight

    obj.muCols = nanmean(obj.gridIm,1);
    obj.muRows = nanmean(obj.gridIm,2);
    xlabel('microns')
    ylabel('microns')

    % Set the axis color scale: clip the top values
    c = caxis;
    caxis([c(1),c(2)*0.7])


    % Graph showing grid along the columns
    subplot(2,2,3)
    h=obj.peakFinder(obj.muCols);
    obj.micsPix.micsPixCols = h.micsPix; %Finds and plots peaks
    obj.micsPix.colFOV = obj.micsPix.micsPixCols*origImageSize(2);
    set(h.line,'color',[1,0.3,0.3], 'linewidth',1);
    set(h.peaks,'MarkerEdgeColor',[0.66,0,0])
    set(h.peaks,'MarkerFaceColor',[1,0.66,0.66])
    title(sprintf('columns: %0.3f \\mum/pixel',h.micsPix))
    % Adds lines to the rotated grid image
    obj.hOverlaidFoundCols = obj.addLinesToImage(h,2,'r');


    % Graph showing grid along the rows
    subplot(2,2,4)
    h=obj.peakFinder(obj.muRows); %Finds and plots peaks
    obj.micsPix.micsPixRows = h.micsPix;
    obj.micsPix.rowFOV = obj.micsPix.micsPixRows*origImageSize(1);
    set(h.line,'color',[0.66,0.66,1], 'linewidth',1);
    set(h.peaks,'MarkerEdgeColor','b')
    set(h.peaks,'MarkerFaceColor',[0.66,0.66,1])
    title(sprintf('rows: %0.3f \\mum/pixel',h.micsPix))
    % Adds lines to the rotated grid image
    obj.hOverlaidFoundRows = obj.addLinesToImage(h,1,'c');



    %Change the axis tick labels in the in the rotated grid image reflect the image size
    nTicks = 5;
    set(obj.hRotatedAx,'XTick', linspace(1,origImageSize(1),nTicks), ...
        'XTickLabel', round(linspace(0,obj.micsPix.colFOV,nTicks)),...
        'YTick', linspace(1,origImageSize(2),nTicks),...
        'YTickLabel', round(linspace(obj.micsPix.rowFOV,0,nTicks)))


    %Update the title on subplot one to report the size of the original image
    origTitle.String = sprintf('%s -- %d \\mum (rows) x %d \\mum (cols)', ...
        origTitle.String, ...
        round(obj.micsPix.micsPixRows*origImageSize(1)), ...
        round(obj.micsPix.micsPixCols*origImageSize(2)) );

    obj.printPixelSizeToScreen %Report to screen the pixel size and FOV



    % UI buttons for returning data and saving data to PDF
    obj.hButtonReturnData = uicontrol('Style','PushButton','String','Return Data', ...
        'Position', [5,5,80,30], 'Callback', @obj.returnData);
    obj.hButtonSavePDF = uicontrol('Style','PushButton','String','Save PDF', ...
        'Position', [85,5,80,30], 'Callback', @obj.savePDF);

    % Buttons for ScanImage interaction
    obj.hButtonNewIm =    uicontrol('Style','PushButton','String','New Image', ....
        'Position', [165,5,80,30], 'Callback', @obj.newGridFromSI);
    obj.hButtonApplyFOV = uicontrol('Style','PushButton','String','Apply FOV', ...
        'Position', [245,5,80,30], 'Callback', @obj.applyCurrentPixelSizeToSI);

    % If ScanImage is not connected we make this buttons unavailable
    if ~obj.scanImageConnected
        obj.hButtonApplyFOV.Enable='Off';
        obj.hButtonNewIm.Enable='Off';
    end



end


