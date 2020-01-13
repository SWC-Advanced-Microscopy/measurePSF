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
    colExtent = h.micsPix*origImageSize(2);
    fprintf('%0.3f mics/pix along columns (width=%0.1f microns)\n', h.micsPix, colExtent)
    obj.micsPix.cols = h.micsPix;
    set(h.line,'color',[1,0.3,0.3], 'linewidth',1);
    set(h.peaks,'MarkerEdgeColor',[0.66,0,0])
    set(h.peaks,'MarkerFaceColor',[1,0.66,0.66])
    title(sprintf('columns: %0.3f \\mum/pixel',h.micsPix))
    obj.addLinesToImage(h,2,'r')

    subplot(2,2,4)
    h=obj.peakFinder(obj.muRows);
    rowExtent = h.micsPix*origImageSize(1);
    fprintf('%0.3f mics/pix along columns (width=%0.1f microns)\n', h.micsPix, rowExtent)
    obj.micsPix.rows = h.micsPix;
    set(h.line,'color',[1,1,1]*0.3, 'linewidth',1);
    set(h.peaks,'MarkerEdgeColor','k')
    set(h.peaks,'MarkerFaceColor',[1,1,1]*0.66)
    title(sprintf('rows: %0.3f \\mum/pixel',h.micsPix))
    obj.addLinesToImage(h,1,'y')


    %Change the axis tick labels in the in the second figure to reflect the image size
    subplot(2,2,2)
    set(gca,'XTick',[1,origImageSize(1)], ...
        'XTickLabel', [0,colExtent],...
        'YTick',[1,origImageSize(2)],...
        'YTickLabel', [rowExtent,0])



    %Update the title on subplot one to report the size of the original image
    origTitle.String = sprintf('%s -- %d \\mum (rows) x %d \\mum (cols)', ...
        origTitle.String, round(obj.micsPix.rows*origImageSize(1)), round(obj.micsPix.cols*origImageSize(2)) );
end

  