function buildFigure(obj)
    % Construct and populate the figure window. 
    % TODO: currently does all the calculations also. So not very modular.

    if isempty(obj.gridIm)
        fprintf('Grid2MicsPerPixel.buildFigure not running: obj.gridIm is empty\n')
        return
    end


    subplot(2,2,1)
    imagesc(obj.origImage)

    origImageSize = size(obj.origImage);
    if obj.cropProp>0
        origTitle=title(sprintf('%d x %d (before cropping)', origImageSize));
    else
        origTitle=title(sprintf('%d x %d', origImageSize));
    end
    axis equal tight


    obj.hRotatedAx = subplot(2,2,2);


    imagesc(obj.gridIm)
    title(sprintf('Corrected tilt by %0.2f degrees',obj.imRotatedAngle))
    axis equal tight


    obj.muCols=nanmean(obj.gridIm,1);
    obj.muRows=nanmean(obj.gridIm,2);

    subplot(2,2,3)
    h=obj.peakFinder(obj.muCols);
    obj.micsPix.micsPixCols = h.micsPix;
    obj.micsPix.colFOV = obj.micsPix.micsPixCols*origImageSize(2);
    set(h.line,'color',[1,0.3,0.3], 'linewidth',1);
    set(h.peaks,'MarkerEdgeColor',[0.66,0,0])
    set(h.peaks,'MarkerFaceColor',[1,0.66,0.66])
    title(sprintf('columns: %0.3f \\mum/pixel',h.micsPix))
    obj.addLinesToImage(h,2,'r')

    subplot(2,2,4)
    h=obj.peakFinder(obj.muRows);
    obj.micsPix.micsPixRows = h.micsPix;
    obj.micsPix.rowFOV = obj.micsPix.micsPixRows*origImageSize(1);
    set(h.line,'color',[1,1,1]*0.3, 'linewidth',1);
    set(h.peaks,'MarkerEdgeColor','k')
    set(h.peaks,'MarkerFaceColor',[1,1,1]*0.66)
    title(sprintf('rows: %0.3f \\mum/pixel',h.micsPix))
    obj.addLinesToImage(h,1,'y')


    %Change the axis tick labels in the in the second figure to reflect the image size
    subplot(2,2,2)
    set(gca,'XTick',[1,origImageSize(1)], ...
        'XTickLabel', [0,obj.micsPix.colFOV],...
        'YTick',[1,origImageSize(2)],...
        'YTickLabel', [obj.micsPix.rowFOV,0])



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

  