classdef measurePSF < handle
    % Display PSF and measure its size in X, Y, and Z
    %
    % measurePSF(PSFstack,micsPerPixelXY,micsPerPixelZ,obj.useMaxIntensityForZpsf)
    %
    % Purpose
    % Fit and display a PSF. Reports FWHM to on-screen figure
    %
    %
    % DEMO MODE - run with no input arguments
    %
    % INPUTS (required)
    % PSFstack  - a 3-D array (imagestack). First layer should be that nearest the objective
    % micsPerPixelZ  - number of microns per pixel in Z (i.e. distance between adjacent Z planes)
    % micsPerPixelXY - number of microns per pixel in X and Y
    % (if the number of microns per pixel is not supplied or is empty, the FWHM estimate for 
    %  that dimension is not displayed to screen)
    %
    % INPUTS (optional param/val pairs)
    % useZmax - [false by default] if true we use the max intensity projection
    %                   for the Z PSFs. This is likely necessary if the PSF is very tilted.
    % zFitOrder - [1 by default]. Number of gaussians to use for the fit of the Z PSF
    % medFiltSize - [1 by default -- no filtering]. If more than one performs a median filtering 
    %               operation on each slice with a filter of this size.
    %
    %
    % OUTPUTS
    % Returns fit objects and various handles (not finalised yet)
    %
    %
    % Rob Campbell - Basel 2016
    %
    %
    % Requires:
    % Curve-Fitting Toolbox, Image Processing Toolbox


    properties (SetAccess=protected)
        PSFstats  %All stats relating to the PSF are stored here. These can be exported to the base workspace using a button
    end


    properties (SetObservable)
        PSFstack %The image stack containing the PSF


        useMaxIntensityForZpsf
        zFitOrder
        medFiltSize % size of the median filter used to clean up the image stack


        % The following are default values. If they aren't changed 
        % (along with the "reportFWHM" properties being true) then
        % the associted FWHM value is not reported.
        micsPerPixelXY=1 % Number of microns per pixel in X/Y
        micsPerPixelZ=1  % Number of microns per pixel in Z
    end


    properties (SetObservable, SetAccess=protected, Hidden)
        % This is the z-plane that contains the brightest region of the bead--we will use this to fit the x/y PSF
        maxZplane
        maxZplaneForFit %These are the data used for fitting. They will always have at least a moderate median filter applied

        %The following are fit-related parameters
        psfCenterInX
        psfCenterInY
        psfCenterInZ
        badFit

        zoomedArea % Area to zoom into if the user has drawn a rectangle over the bottom/left image. 
                   % Should be [bottom_pos, left_pos, width, height]
                   % See "areaSelector" and "resetView" callbacks.
    end

    properties (Hidden, SetAccess=protected)
        PSFstack_Orig %The original (unzoomed) stack
    end

    properties (Hidden)
        hFig % Handle containing the figure
        hPSF_XYmidpointImageAx % The PSF at the estimated mid-point (bottom left image)
        hPSF_XYmidpointImageIM % Handle to the image object
        hPS_midPointImageXhairs % The dashed cross-hairs
        hPSF_midPointText

        hxSectionRowsAx
        hxSectionColsAx
        hPSF_ZXax
        hPSF_ZX_fitAx
        hPSF_ZYax
        hPSF_ZY_fitAx

        hUserSelectedPlaneAx % Handle to the axis showing the user-selected plane within the PSF
        hUserSelectedPlaneIM
        hUserSelectedPlaneTitle

        hSlider % Slider handle


        drawBox_PushButton
        reset_PushButton
        fitToBaseWorkSpace_PushButton

        showHelpTextIfTooFewArgsProvided=false
        listeners={}

        % If user does not supply a pixel size then the associated FWHM value will not be reported nto screen 
        reportFWHMxy=false
        reportFWHMz=false
    end




    methods
        function obj=measurePSF(inputPSFstack,micsPerPixelZ,micsPerPixelXY,varargin)


            if nargin<1 || isempty(inputPSFstack)
                if obj.showHelpTextIfTooFewArgsProvided
                    help(mfilename)
                end
                demoMode=true;
                % We will display the default PSF and use the default values for XY and Z pixel size
                % as defined in the properties section
                % The default PSF is loaded at the end of the constructor
            else
                demoMode=false;
            end

            if nargin>1 && isnumeric(micsPerPixelZ) && isscalar(micsPerPixelZ)
                obj.micsPerPixelZ = micsPerPixelZ;
                obj.reportFWHMz=true;
            end

            if nargin>2 && isnumeric(micsPerPixelXY) && isscalar(micsPerPixelXY)
                obj.micsPerPixelXY = micsPerPixelXY;
                obj.reportFWHMxy=true;
            end


            params = inputParser;
            params.CaseSensitive = false;
            params.addParamValue('useZmax', 1, @(x) islogical(x) || x==0 || x==1);
            params.addParamValue('zFitOrder', 1, @(x) isnumeric(x) && isscalar(x));
            params.addParamValue('medFiltSize', 1, @(x) isnumeric(x) && isscalar(x));

            params.parse(varargin{:});

            obj.useMaxIntensityForZpsf = params.Results.useZmax;
            obj.zFitOrder = params.Results.zFitOrder;
            obj.medFiltSize = params.Results.medFiltSize;


            % Make empty data and generate empty plots using these
            obj.PSFstack = zeros(2^8);
            obj.maxZplane = zeros(2^8);
            obj.maxZplaneForFit = zeros(2^8);
            obj.psfCenterInX=2^7;
            obj.psfCenterInZ=2^7;
            obj.psfCenterInZ=1;


            obj.setUpFigureWindow % Make the axes and so forth


            % Set up listeners that will update the plots when the PSF stack is modified or 
            % other relevant properties are changed. 
            obj.listeners{end+1} = addlistener(obj, 'PSFstack', 'PostSet', @obj.plotNewImageStack);
            obj.listeners{end+1} = addlistener(obj, 'maxZplaneForFit', 'PostSet', @obj.fitPSFandUpdateSlicePlots);
            %obj.listeners{end+1} = addlistener(obj, 'zoomedArea', 'PostSet', @obj.fitPSFandUpdateSlicePlots); %so zooming works


            % If no PSF stack was provided, we loads the default
            if demoMode
                P = load('PSF');
                obj.zoomedArea = [1,1,size(P.PSF,1)-1,size(P.PSF,2)-1];
                obj.PSFstack_Orig = P.PSF;
                obj.PSFstack = P.PSF;
            else
                obj.zoomedArea = [1,1,size(inputPSFstack,1)-1,size(inputPSFstack,2)-1];
                obj.PSFstack_Orig = inputPSFstack;
                obj.PSFstack = inputPSFstack;
            end

        end %Close constructor


        function delete(obj)
            cellfun(@delete,obj.listeners)
            obj.hFig.delete
        end % Close destructor


        function windowCloseFcn(obj,~,~)
            % This runs when the user closes the figure window
            obj.delete % simply call the destructor
        end % Close windowCloseFcn


        function denoiseImStackAndFindPSFcenterInZ(obj)
            % Estimate the slice that contains center of the PSF in Z by finding the brightest point.
            obj.PSFstack = double(obj.PSFstack);
            for ii = 1:size(obj.PSFstack,3)
                obj.PSFstack(:,:,ii) =  medfilt2(obj.PSFstack(:,:,ii),[obj.medFiltSize,obj.medFiltSize]);
            end
            obj.PSFstack = obj.PSFstack - median(obj.PSFstack(:)); %subtract the baseline because the Gaussian fit doesn't have an offset parameter

            %Further clean the image stack since we will use the max command to find the peak location
            DS = imresize(obj.PSFstack,0.25); 
            for ii = 1:size(DS,3)
                DS(:,:,ii) = conv2(DS(:,:,ii),ones(2),'same');
            end
            Z = max(squeeze(max(DS))); 

            z = max(squeeze(max(DS)));
            f = obj.fit_Intensity(z,1,1); 
            obj.psfCenterInZ = round(f.b1);

            if obj.psfCenterInZ > size(obj.PSFstack,3) || obj.psfCenterInZ<1
                fprintf('PSF center in Z estimated as slice %d. That is out of range. PSF stack has %d slices\n',...
                    obj.psfCenterInZ,size(obj.PSFstack,3))
                fprintf('Setting centre to mid-point of stack\n')
                obj.psfCenterInZ=round(size(obj.PSFstack,3));
            end

            obj.maxZplane = obj.PSFstack(:,:,obj.psfCenterInZ);
            % We will use this plane to find the bead in X and Y by fitting gaussians along these dimensions.
            % We will use these values to show cross-sections of it along X and Y.
            % Always apply a moderate median filter to help ensure we get a reasonable fit
            if obj.medFiltSize==1
                obj.maxZplaneForFit = medfilt2(obj.maxZplane,[2,2]); %Filter this plane alone if no filtering was requested
            else
                obj.maxZplaneForFit = obj.maxZplane;
            end

        end %Close denoiseImStackAndFindPSFcenterInZ



        %-----------------------------------------------------------------------------
        % Callback functions follow
        function plotNewImageStack(obj,~,~)
            %This is run when the PSFstack property is changed
            s=size(obj.PSFstack);
            obj.hFig.Name = sprintf('Image size: %d x %d',s(1:2));

            %Clean the stack and find the mid-point and produce a filtered image plane at this point
            obj.denoiseImStackAndFindPSFcenterInZ;

            %Plot the mid-point of the stack
            obj.hPSF_XYmidpointImageIM.CData = obj.maxZplane;

            %Update overlay text
            obj.hPSF_midPointText.Position(1) = size(obj.PSFstack,1)*0.025;
            obj.hPSF_midPointText.Position(2) = size(obj.PSFstack,2)*0.04;
            obj.hPSF_midPointText.String = sprintf('PSF center at slice #%d',obj.psfCenterInZ);


            %Optionally, show the axes. Right now, I don't think we want this at all so it's not an input argument 
            showAxesInMainPSFplot=0;
            if showAxesInMainPSFplot
                Xtick = linspace(1,size(obj.maxZplane,1),8);
                Ytick = linspace(1,size(obj.maxZplane,2),8);
                set(obj.PSF_XYmidpointImageAx,'XTick',Xtick,'XTickLabel',round(Xtick*obj.micsPerPixelXY,2),...
                        'YTick',Ytick,'YTickLabel',round(Ytick*obj.micsPerPixelXY,2));
            else
                set(obj.hPSF_XYmidpointImageAx,'XTick',[],'YTick',[], ...
                    'XLim',[0,size(obj.PSFstack,1)], ...
                    'YLim',[0,size(obj.PSFstack,2)])
            end

            % Place image into the top/right plot and update the slider
            obj.hUserSelectedPlaneIM.CData = obj.maxZplane;
            set(obj.hSlider, 'Max',size(obj.PSFstack,3), 'Value',obj.psfCenterInZ)


            % Modify the lines to show where we are slicing it to take the cross-sections
            obj.setCrossSectionLinesInMainPSFImage 

            obj.hUserSelectedPlaneTitle.String = sprintf('Slice #%d', obj.psfCenterInZ);
        end % Close plotNewImageStack


        function setCrossSectionLinesInMainPSFImage(obj,~,~)
            %Set new cross-hair location on the bottom/left image based upon the 
            %x/y centroid of the bead (PSF)
            set(obj.hPS_midPointImageXhairs(1), 'XData', obj.hPSF_XYmidpointImageAx.XLim, ...
                'YData', [obj.psfCenterInY,obj.psfCenterInY])
            set(obj.hPS_midPointImageXhairs(2), 'XData', [obj.psfCenterInX,obj.psfCenterInX], ...
                'YData', obj.hPSF_XYmidpointImageAx.YLim)
        end % Close setCrossSectionLinesInMainPSFImage


        function fitPSFandUpdateSlicePlots(obj,~,~)
            % This callback is run whenever the raw data are updated or
            % whenever properties that might affect the fit are updated.

             % Find the X/Y max location (TODO: in future this coould be of a sub-region defined by a rectangle)
            obj.findPSF_centreInXY(obj.maxZplaneForFit);

            %The cross-section sliced along the rows (the fit shown along the right side of the X/Y PSF)
            axes(obj.hxSectionRowsAx);
            cla %TODO -- This isn't great, but it works (see below)
            yvals = obj.maxZplane(:,obj.psfCenterInX);
            x=(1:length(yvals))*obj.micsPerPixelXY;
            fitX = obj.fit_Intensity(yvals,obj.micsPerPixelXY,1);
            obj.plotCrossSectionAndFit(x,yvals,fitX,obj.micsPerPixelXY/2,1); %TODO -- Would be best to change plot object props and not CLA each time
            X.xVals=x;
            X.yVals=yvals;
            set(obj.hxSectionRowsAx,'XTickLabel',[])

            %Supress title with FWHM estimate if no mics per pixel was provided
            if ~obj.reportFWHMxy
                title('')
            end
            obj.PSFstats.X.fit = fitX;
            obj.PSFstats.X.data = X;

            %The cross-section sliced down the columns (fit shown above the X/Y PSF)
            axes(obj.hxSectionColsAx);
            cla
            yvals = obj.maxZplane(obj.psfCenterInY,:);
            x=(1:length(yvals))*obj.micsPerPixelXY;
            fitY = obj.fit_Intensity(yvals,obj.micsPerPixelXY);
            obj.plotCrossSectionAndFit(x,yvals,fitY,obj.micsPerPixelXY/2);
            Y.xVals=x;
            Y.yVals=yvals;
            set(obj.hxSectionColsAx,'XTickLabel',[])

            %Supress title with FWHM estimate if no mics per pixel was provided
            if ~obj.reportFWHMxy
                title('')
            end
            obj.PSFstats.Y.fit = fitY;
            obj.PSFstats.Y.data = Y;

            % Obtain images showing the PSF's extent in Z
            % We do this by taking maximum intensity projections or slices through the maximum

            %PSF in Z/X (upper panel)
            if obj.useMaxIntensityForZpsf
                PSF_ZX=squeeze(max(obj.PSFstack,[],1));
            else
                PSF_ZX=squeeze(obj.PSFstack(obj.psfCenterInY,:,:));
            end

            imagesc(obj.hPSF_ZXax, PSF_ZX)

            Ytick = linspace(1,size(PSF_ZX,1),3);
            set(obj.hPSF_ZXax,'XAxisLocation','Top',...
                    'XTick',[],...
                    'YTick',Ytick,'YTickLabel',round(Ytick*obj.micsPerPixelXY,2));

            %This is the fitted Z/Y PSF with the FWHM
            axes(obj.hPSF_ZX_fitAx)
            cla
            maxPSF_ZX = max(PSF_ZX,[],1);
            baseline = sort(maxPSF_ZX);
            baseline = mean(baseline(1:5));
            maxPSF_ZX = maxPSF_ZX-baseline;

            fitZX = obj.fit_Intensity(maxPSF_ZX, obj.micsPerPixelZ);
            x = (1:length(maxPSF_ZX))*obj.micsPerPixelZ;
            [OUT.ZX.FWHM,OUT.ZX.fitPlot_H] = obj.plotCrossSectionAndFit(x,maxPSF_ZX,fitZX,obj.micsPerPixelZ/4);
            set(obj.hPSF_ZX_fitAx,'XAxisLocation','Top')

            %Supress title with FWHM estimate if no mics per pixel was provided
            if ~obj.reportFWHMz
                title('')
            end
            obj.PSFstats.ZX.im = maxPSF_ZX;
            obj.PSFstats.ZX.fit = fitZX;


            % PSF in Z/Y (panel on the right on the right)
            if obj.useMaxIntensityForZpsf
                PSF_ZY=squeeze(max(obj.PSFstack,[],2));
            else
                PSF_ZY=squeeze(obj.PSFstack(:,obj.psfCenterInX,:));
            end

            PSF_ZY=rot90(PSF_ZY,3);
            imagesc(obj.hPSF_ZYax, PSF_ZY)

            Xtick = linspace(1,size(PSF_ZY,2),3);
            set(obj.hPSF_ZYax,'YAxisLocation','Right',...
                    'XTick',Xtick,'XTickLabel',round(Xtick*obj.micsPerPixelXY,2),...
                    'YTick',[])

            %This is the fitted Z/X PSF with the FWHM
            axes(obj.hPSF_ZY_fitAx);
            cla
            maxPSF_ZY = max(PSF_ZY,[],2);
            baseline = sort(maxPSF_ZY);
            baseline = mean(baseline(1:5));
            maxPSF_ZY = maxPSF_ZY-baseline;

            fitZY = obj.fit_Intensity(maxPSF_ZY, obj.micsPerPixelZ);
            x = (1:length(maxPSF_ZY))*obj.micsPerPixelZ;
            [OUT.ZY.FWHM, OUT.ZY.fitPlot_H] = obj.plotCrossSectionAndFit(x,maxPSF_ZY,fitZY,obj.micsPerPixelZ/4,1);
            set(obj.hPSF_ZY_fitAx,'XAxisLocation','Top')

            %Supress title with FWHM estimate if no mics per pixel was provided
            if ~obj.reportFWHMz
                title('')
            end
            obj.PSFstats.ZY.im = maxPSF_ZY;
            obj.PSFstats.ZY.fit = fitZY;
        end % Close fitPSFandUpdateSlicePlots


        function updateUserSelected(obj,~,~)
            % Runs when the user moves the slider
            thisSlice = round(get(obj.hSlider,'Value'));
            obj.hUserSelectedPlaneIM.CData = obj.PSFstack(:,:,thisSlice);

            caxis([min(obj.PSFstack(:)), max(obj.PSFstack(:))])

            obj.hUserSelectedPlaneTitle.String = sprintf('Slice #%d', thisSlice);
        end %Close updateUserSelected


        function copyFitToBaseWorkSpace(obj,~,~)
            % Copy the PSFstats property to the base workspace. 
            if isempty(obj.PSFstats)
                return
            end

            varName = 'PSFstats';
            fprintf('Copying PSF fit to base work space as variable "%s"\n', varName)

            assignin('base',varName, obj.PSFstats)
        end % Close copyFitToBaseWorkSpace


        function areaSelector(obj,~,~)
            %select a sub-region of the bottom left plots
            h = imrect(obj.hPSF_XYmidpointImageAx);
            rect_pos = wait(h);
            obj.zoomedArea = round([rect_pos(1:2), mean(rect_pos(3:4)), mean(rect_pos(3:4))]);
            delete(h)
            za = obj.zoomedArea;

            obj.PSFstack = obj.PSFstack(za(1):za(1)+za(3), za(2):za(2)+za(4), :);

            obj.updateUserSelected

        end % Close areaSelector

        function resetView(obj,~,~)
            % Unzoom other panels
            resetSize = [1,1,size(obj.PSFstack_Orig,1)-1,size(obj.PSFstack_Orig,2)-1];

            %Only apply if different to avoid hitting listeners    
            if ~isequal(obj.zoomedArea,resetSize)
                obj.zoomedArea=resetSize;
                obj.PSFstack = obj.PSFstack_Orig;
                obj.updateUserSelected
            end
        end % Close areaSelector


    end % close methods
end
