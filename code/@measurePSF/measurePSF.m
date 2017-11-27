classdef measurePSF < handle
    % Display PSF and measure its size in X, Y, and Z
    %
    % measurePSF(PSFstack,micsPerPixelXY,micsPerPixelZ,obj.useMaxIntensityForZpsf)
    %
    % Purpose
    % Fit and display a PSF. Reports FWHM to on-screen figure
    % Note: currently uses two-component fits for the PSF in Z. This may be a bad choice
    %       for 2-photon PSFs or PSFs which are sparsely sampled in Z. Will need to look 
    %       at real data and decide what to do about the Z-fits. So far only tried simulated
    %       PSFs.
    %
    %
    % DEMO MODE - run with no input arguments
    %
    % INPUTS (required)
    % PSFstack  - a 3-D array (imagestack). First layer should be that nearest the objective
    % micsPerPixelXY - number of microns per pixel in X and Y
    % micsPerPixelZ  - number of microns per pixel in Z (i.e. distance between adjacent Z planes)
    %
    % INPUTS (optional param/val pairs)
    % obj.useZmax - [false by default] if true we use the max intensity projection
    %                   for the Z PSFs. This is likely necessary if the PSF is very tilted.
    % obj.zFitOrder - [1 by default]. Number of gaussians to use for the fit of the Z PSF
    % medFiltSize - [1 by default -- no filtering]. If more than one performs a median filtering 
    %               operation on each slice with a filter of this size.
    % frameSize - [false by default] If a scalar, frameSize is used to zoom into the location of the
    %             the identified bead. e.g. if frameSize is 50, a 50 by 50 pixel window is centered 
    %             on the bead. 
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


    properties
        hFig % Handle containing the figure
    end

    properties(SetObservable)
        PSFstack %The image stack containing the PSF


        useMaxIntensityForZpsf
        zFitOrder
        medFiltSize % size of the median filter used to clean up the image stack


        % The following are default values
        micsPerPixelXY = 0.05 %Number of microns per pixel in X/Y
        micsPerPixelZ  = 0.5  %Number of microns per pixel in Z
    end

    properties(SetAccess=protected, Hidden)

        %The following are fit-related parameters
        psfCenterInX
        psfCenterInY
        psfCenterInZ
        badFit
    end

    properties(Hidden)
        hPSF_XYmidpointImageAx % The PSF at the estimated mid-point (bottom left image)
        hxSectionRowsAx
        hxSectionColsAx
        hPSF_ZXax
        hPSF_ZX_fitAx
        hPSF_ZYax
        hPSF_ZY_fitAx

        hUserSelectedPlaneAx % Handle to the axis showing the user-selected plane within the PSF
        hUserSelectedPlaneIM
        hSlider % Slider handle
        
        drawBox_PushButton 
        fitToBaseWorkSpace_PushButton

    end




    methods
        function obj=measurePSF(PSFstack,micsPerPixelXY,micsPerPixelZ,varargin)


            if nargin<1
                help(mfilename)
                % We will display the default PSF and use the default values for XY and Z pixel size
                % as defined in the properties section
                P=load('PSF');
                obj.PSFstack = P.PSF;
            elseif nargin<3
                fprintf('\n\n ----> Function requires three input arguments! <---- \n\n')
                help(mfilename)
                return
            end



            params = inputParser;
            params.CaseSensitive = false;
            params.addParamValue('useZmax', 1, @(x) islogical(x) || x==0 || x==1);
            params.addParamValue('zFitOrder', 1, @(x) isnumeric(x) && isscalar(x));
            params.addParamValue('medFiltSize', 1, @(x) isnumeric(x) && isscalar(x));
            params.addParamValue('frameSize',false, @(x) x==false || (isnumeric(x) && isscalar(x)) )

            params.parse(varargin{:});

            obj.useMaxIntensityForZpsf = params.Results.useZmax;
            obj.zFitOrder = params.Results.zFitOrder;
            obj.medFiltSize = params.Results.medFiltSize;
            frameSize = params.Results.frameSize;





            % Step One
            %
            % Estimate the slice that contains center of the PSF in Z by finding the brightest point.
            obj.denoiseImStackAndFindPSFcenterInZ;



            % Step Two
            %
            % Find the center of the bead in X and Y by fitting gaussians along these dimensions.
            % We will use these values to show cross-sections of it along X and Y at the level of the image plotted above.
            % Always apply a moderate median filter to help ensure we get a reasonable fit
            maxZplane = obj.PSFstack(:,:,obj.psfCenterInZ);
            if obj.medFiltSize==1
                maxZplaneForFit = medfilt2(maxZplane,[2,2]);
            else
                maxZplaneForFit = maxZplane;
            end

            obj.findPSF_centre(maxZplaneForFit);


            if isnumeric(frameSize) && ~obj.badFit %Zoom into the bead if the user asked for this
                x=(-frameSize/2 : frameSize/2)+obj.psfCenterInX;
                y=(-frameSize/2 : frameSize/2)+obj.psfCenterInY;
                x=round(x);
                y=round(y);

                maxZplaneForFit = maxZplaneForFit(y,x);
                maxZplane = maxZplane(y,x);
                obj.PSFstack = obj.PSFstack(y,x,:);

                obj.findPSF_centre(maxZplaneForFit);

            end


            %Plot the mid-point of the stack
            obj.hFig = figure;
            obj.hFig.CloseRequestFcn = @obj.windowCloseFcn;
            obj.hFig.Position(3) = 800;
            obj.hFig.Position(4) = 800;

            s=size(obj.PSFstack);
            set(gcf,'Name',sprintf('Image size: %d x %d',s(1:2)))
            %PSF at mid-point
            obj.hPSF_XYmidpointImageAx = axes('Position',[0.03,0.07,0.4,0.4]);
            imagesc(maxZplane)

            text(size(obj.PSFstack,1)*0.025,...
                size(obj.PSFstack,2)*0.04,...
                sprintf('PSF center at slice #%d',obj.psfCenterInZ),...
                'color','w','VerticalAlignment','top') 


            %Optionally, show the axes. Right now, I don't think we want this at all so it's not an input argument 
            showAxesInMainPSFplot=0;
            if showAxesInMainPSFplot
                Xtick = linspace(1,size(maxZplane,1),8);
                Ytick = linspace(1,size(maxZplane,2),8);
                set(gca,'XTick',Xtick,'XTickLabel',round(Xtick*obj.micsPerPixelXY,2),...
                        'YTick',Ytick,'YTickLabel',round(Ytick*obj.micsPerPixelXY,2));
            else
                set(gca,'XTick',[],'YTick',[])
            end


            %Add lines to the main X/Y plot showing where we are slicing it to take the cross-sections
            hold on
            plot(xlim,[obj.psfCenterInY,obj.psfCenterInY],'--w')
            plot([obj.psfCenterInX,obj.psfCenterInX],ylim,'--w')
            hold off


            %The cross-section sliced along the rows (the fit shown along the right side of the X/Y PSF)
            obj.hxSectionRowsAx = axes('Position',[0.435,0.07,0.1,0.4]);
            yvals = maxZplane(:,obj.psfCenterInX);
            x=(1:length(yvals))*obj.micsPerPixelXY;
            fitX = obj.fit_Intensity(yvals,obj.micsPerPixelXY,1);
            obj.plotCrossSectionAndFit(x,yvals,fitX,obj.micsPerPixelXY/2,1);
            X.xVals=x;
            X.yVals=yvals;
            set(gca,'XTickLabel',[])


            %The cross-section sliced down the columns (fit shown above the X/Y PSF)
            obj.hxSectionColsAx=axes('Position',[0.03,0.475,0.4,0.1]);
            yvals = maxZplane(obj.psfCenterInY,:);
            x=(1:length(yvals))*obj.micsPerPixelXY;
            fitY = obj.fit_Intensity(yvals,obj.micsPerPixelXY);
            obj.plotCrossSectionAndFit(x,yvals,fitY,obj.micsPerPixelXY/2);
            Y.xVals=x;
            Y.yVals=yvals;
            set(gca,'XTickLabel',[])



            % Step Three
            %
            % We now obtain images showing the PSF's extent in Z
            % We do this by taking maximum intensity projections or slices through the maximum
            obj.hPSF_ZXax = axes('Position',[0.03,0.6,0.4,0.25]);


            %PSF in Z/X (panel above)
            if obj.useMaxIntensityForZpsf
                PSF_ZX=squeeze(max(obj.PSFstack,[],1));
            else
                PSF_ZX=squeeze(obj.PSFstack(obj.psfCenterInY,:,:));
            end

            imagesc(PSF_ZX)

            Ytick = linspace(1,size(PSF_ZX,1),3);
            set(gca,'XAxisLocation','Top',...
                    'XTick',[],...
                    'YTick',Ytick,'YTickLabel',round(Ytick*obj.micsPerPixelXY,2));

            text(1,1,sprintf('PSF in Z/X'), 'Color','w','VerticalAlignment','top');

            %This is the fitted Z/Y PSF with the FWHM
            obj.hPSF_ZX_fitAx = axes('Position',[0.03,0.85,0.4,0.1]);
            maxPSF_ZX = max(PSF_ZX,[],1);
            baseline = sort(maxPSF_ZX);
            baseline = mean(baseline(1:5));
            maxPSF_ZX = maxPSF_ZX-baseline;

            fitZX = obj.fit_Intensity(maxPSF_ZX, obj.micsPerPixelZ);
            x = (1:length(maxPSF_ZX))*obj.micsPerPixelZ;
            [OUT.ZX.FWHM,OUT.ZX.fitPlot_H] = obj.plotCrossSectionAndFit(x,maxPSF_ZX,fitZX,obj.micsPerPixelZ/4);
            set(gca,'XAxisLocation','Top')




            %PSF in Z/Y (panel on the right on the right)
            obj.hPSF_ZYax=axes('Position',[0.56,0.07,0.25,0.4]);
            if obj.useMaxIntensityForZpsf
                PSF_ZY=squeeze(max(obj.PSFstack,[],2));
            else
                PSF_ZY=squeeze(obj.PSFstack(:,obj.psfCenterInX,:));
            end

            PSF_ZY=rot90(PSF_ZY,3);
            imagesc(PSF_ZY)

            Xtick = linspace(1,size(PSF_ZY,2),3);
            set(gca,'YAxisLocation','Right',...
                    'XTick',Xtick,'XTickLabel',round(Xtick*obj.micsPerPixelXY,2),...
                    'YTick',[])

            text(1,1,sprintf('PSF in Z/Y'), 'Color','w','VerticalAlignment','top');

            %This is the fitted Z/X PSF with the FWHM
            obj.hPSF_ZY_fitAx = axes('Position',[0.8,0.07,0.1,0.4]);
            maxPSF_ZY = max(PSF_ZY,[],2);
            baseline = sort(maxPSF_ZY);
            baseline = mean(baseline(1:5));
            maxPSF_ZY = maxPSF_ZY-baseline;

            fitZY = obj.fit_Intensity(maxPSF_ZY, obj.micsPerPixelZ);
            x = (1:length(maxPSF_ZY))*obj.micsPerPixelZ;
            [OUT.ZY.FWHM, OUT.ZY.fitPlot_H] = obj.plotCrossSectionAndFit(x,maxPSF_ZY,fitZY,obj.micsPerPixelZ/4,1);
            set(gca,'XAxisLocation','Top')



            % Step Four
            %
            % Add a plot with a scroll-bar so we can view the PSF as desires
            obj.hUserSelectedPlaneAx = axes('Position',[0.5,0.55,0.4,0.4]);
            obj.hUserSelectedPlaneIM=imagesc(maxZplane);

            box on
            set(gca,'XTick',[],'YTick',[])

            obj.hSlider = uicontrol('Style','Slider', ...
                        'Units','normalized',...
                        'Position',[0.9,0.55,0.02,0.4],...
                        'Min',1,...
                        'Max',size(obj.PSFstack,3),...
                        'Value',obj.psfCenterInZ,...
                        'Tag','DepthSlider',...
                        'Callback', @obj.updateUserSelected );

            title(sprintf('Slice #%d', obj.psfCenterInZ))


            % Step Five
            % Add further UI elements
            obj.drawBox_PushButton = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
                'Position', [0.025, 0.025, 0.10, 0.04], 'String', 'Select bead');

            obj.fitToBaseWorkSpace_PushButton = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
                'Position', [0.135, 0.025, 0.10, 0.04], 'String', 'Fit to base WS', ...
                'ToolTip', 'Copy parameters to the base workspace', ...
                'Callback', @obj.copyFitToBaseWorkSpace);


            if isempty(obj.PSFstack)
                P=load('PSF');
                obj.PSFstack = P.PSF;
            end
        end


        function delete(obj)
            obj.hFig.delete
        end

        function windowCloseFcn(obj,~,~)
            % This runs when the user closes the figure window
            obj.delete % simply call the destructor
        end %close windowCloseFcn



        function denoiseImStackAndFindPSFcenterInZ(obj)
            % Estimate the slice that contains center of the PSF in Z by finding the brightest point.
            obj.PSFstack = double(obj.PSFstack);
            for ii=1:size(obj.PSFstack,3)
                obj.PSFstack(:,:,ii) =  medfilt2(obj.PSFstack(:,:,ii),[obj.medFiltSize,obj.medFiltSize]);
            end
            obj.PSFstack = obj.PSFstack - median(obj.PSFstack(:)); %subtract the baseline because the Gaussian fit doesn't have an offset parameter

            %Further clean the image stack since we will use the max command to find the peak location
            DS = imresize(obj.PSFstack,0.25); 
            for ii=1:size(DS,3)
                DS(:,:,ii) = conv2(DS(:,:,ii),ones(2),'same');
            end
            Z = max(squeeze(max(DS))); 

            z=max(squeeze(max(DS)));
            f = obj.fit_Intensity(z,1,1); 
            obj.psfCenterInZ = round(f.b1);

            if obj.psfCenterInZ > size(obj.PSFstack,3) || obj.psfCenterInZ<1
                fprintf('PSF center in Z estimated as slice %d. That is out of range. PSF stack has %d slices\n',...
                    obj.psfCenterInZ,size(obj.PSFstack,3))
                fprintf('Setting centre to mid-point of stack\n')
                obj.psfCenterInZ=round(size(obj.PSFstack,3));
                return
            end
        end



        %-----------------------------------------------------------------------------
        % Callback functions follow
        function updateUserSelected(obj,~,~)
            % Runs when the user moves the slider

            thisSlice = round(get(obj.hSlider,'Value'));
            obj.hUserSelectedPlaneIM.CData = obj.PSFstack(:,:,thisSlice);

            caxis([min(obj.PSFstack(:)), max(obj.PSFstack(:))])

            title(sprintf('Slice #%d %0.2f \\mum', thisSlice, (obj.psfCenterInZ-thisSlice)*obj.micsPerPixelZ ))
        end

        function copyFitToBaseWorkSpace(obj,~,~)

            %TODO: if fit is not present return
            if 1
                return
            end

            %TODO: if fit is present assemble structure and copy to base workspace
            varName = PSFfit;
            fprintf('Copying PSF fit to base work space as variable "%s"\n', varName)

            OUT.Y.fit  = fitY;
            OUT.Y.data  = Y;
            OUT.X.fit  = fitX;
            OUT.X.data  = X;
            OUT.ZY.fit = fitZY;
            OUT.ZX.fit = fitZY;
            OUT.ZX.im = PSF_ZX;
            OUT.ZY.im = PSF_ZY;

            assignin('base',varName, OUT)
        end


    end % close methods
end
