function setUpFigureWindow(obj)
    % Set up the measurePSF figure window by placing empty axes and 
    % place-holder plot elements that will later be updated. 

    % Create a figure window 
    obj.hFig = figure;
    obj.hFig.CloseRequestFcn = @obj.windowCloseFcn;
    obj.hFig.Position(3) = 800;
    obj.hFig.Position(4) = 800;

    %Add plot axes and empty plot elements

    % The bottom/left plot showing a cross-section through maximum brightness region
    obj.hPSF_XYmidpointImageAx = axes('Position',[0.03,0.07,0.4,0.4]);
    obj.hPSF_XYmidpointImageIM = imagesc(obj.hPSF_XYmidpointImageAx, obj.maxZplane);

    %Add place-holder lines to the main X/Y plot showing where we are slicing it to take the cross-sections
    hold on
    obj.hPS_midPointImageXhairs(1)=plot(xlim,[0,0],'--w');
    obj.hPS_midPointImageXhairs(2)=plot([0,0],ylim,'--w');
    obj.hPSF_midPointText = text(0,0,'', 'color','w', 'VerticalAlignment','top');
    hold off


    %The cross-section sliced along the rows (the fit shown along the right side of the X/Y PSF)
    obj.hxSectionRowsAx = axes('Position',[0.435,0.07,0.1,0.4]);

    %The cross-section sliced down the columns (fit shown above the X/Y PSF)
    obj.hxSectionColsAx=axes('Position',[0.03,0.475,0.4,0.1]);

    %Axes for axial PSF cross-sections
    obj.hPSF_ZXax = axes('Position',[0.03,0.6,0.4,0.25]);
    text(1,1,sprintf('PSF in Z/X'), 'Color','w','VerticalAlignment','top');
    obj.hPSF_ZX_fitAx = axes('Position',[0.03,0.85,0.4,0.1]);

    obj.hPSF_ZYax=axes('Position',[0.56,0.07,0.25,0.4]);
    text(1,1,sprintf('PSF in Z/Y'), 'Color','w','VerticalAlignment','top');
    obj.hPSF_ZY_fitAx = axes('Position',[0.8,0.07,0.1,0.4]);


    % Add a plot with a scroll-bar so we can view the PSF as desires
    obj.hUserSelectedPlaneAx = axes('Position',[0.5,0.55,0.4,0.4]);
    obj.hUserSelectedPlaneIM = imagesc(obj.maxZplane);
    set(obj.hUserSelectedPlaneAx,'XTick',[],'YTick',[], 'Box', 'On')
    axis tight %Used for zooming to work nicely
    obj.hSlider = uicontrol('Style','Slider', ...
                        'Units','normalized',...
                        'Position',[0.9,0.55,0.02,0.4],...
                        'Min',1,...
                        'Max',size(obj.PSFstack,3),...
                        'Value',obj.psfCenterInZ,...
                        'Tag','DepthSlider',...
                        'Callback', @obj.updateUserSelected );

    obj.hUserSelectedPlaneTitle=title(sprintf('Slice #%d', obj.psfCenterInZ));


    % Add further UI elements
    obj.drawBox_PushButton = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
                'Position', [0.025, 0.025, 0.10, 0.04], 'String', 'Select bead', ...
                'ToolTip', 'Manually select a sub-region of the image', ...
                'Callback', @obj.areaSelector);

    obj.reset_PushButton = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
                'Position', [0.135, 0.025, 0.10, 0.04], 'String', 'Reset view', ...
                'ToolTip', 'Zoom out and reset view', ...
                'Callback', @obj.resetView);

    obj.fitToBaseWorkSpace_PushButton = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
                'Position', [0.245, 0.025, 0.10, 0.04], 'String', 'Fit to base WS', ...
                'ToolTip', 'Copy parameters to the base workspace', ...
                'Callback', @obj.copyFitToBaseWorkSpace);
end

