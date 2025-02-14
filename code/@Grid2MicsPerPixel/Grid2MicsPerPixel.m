classdef Grid2MicsPerPixel < handle

    properties
        % The following properties have default values defined in the constructor
        gridPitch
        verbose
        cropProp
        polynomDetrendOrder
        medFiltSize

        % The grid image
        gridIm
        origImage %before cropping, etc, see prepareImageForDisplay
        imRotatedAngle % Angle by which the image was rotated to make it square with axes

        % Plot object handles
        hFig
        figName = 'Grid2MicsPerPixel'
        hRotatedAx % Axes in which the grid image has been rotated
        hButtonReturnData
        hButtonSavePDF
        hButtonNewIm
        hButtonApplyFOV
        hOverlaidFoundRows
        hOverlaidFoundCols

        % Any listeners should be attached to this cell array
        listeners = {}

        % Data derived from image and used to measure the number of microns per pixel
        muCols %The mean of the rotated grid image along the columns (first axis)
        muRows %The mean of the rotated grid image along the rows (second axis)
        micsPix %Structure storing the number of microns per pixel
        rotImage = 0; %If zero the image is not rotated after loading from SI. If
                 %this is 1 we do 90 deg. If 2 180.
    end % properties


    properties (SetObservable)
        scanImageConnected %If true, ScanImage is presented and connected
    end


    methods
        function obj=Grid2MicsPerPixel(inputIM,varargin)
            % Calculated the number of microns per pixel based on an imaged grid of known pitch
            %
            % function obj=Grid2MicsPerPixel(inputIM, 'param', 'val')
            %
            % Purpose
            % Calculates the number of microns per pixel along rows and columns from
            % an imaged grid of known pitch. NOTE: It's important that most of the grid lines
            % are found since the number of microns per pixel is based upon the median spacing
            % between adjacent identified grid lines. e.g. if the algorithm finds every other
            % line the number of microns per pixel will be half the size it should be. Alternatively,
            % missing, say, the two outer grid lines one one side will have no effect. Try tweaking
            % cropProp, medFiltSize, and polynomDetrendOrder to capture more grid lines if needed.
            %
            %
            % Inputs
            % inputIM - 2D image of the grid. If empty or no input arguments provided, Grid2MicsPerPixel
            %           attempts to extract the grid image from the running instance of ScanImage. i.e.
            %           it assumes a grid is currently being displayed in the channel windows.
            %
            % Inputs (optional param/val pairs)
            % gridPitch   - pitch of the grid in microns (default is 25)
            % cropProp    -  proportion of image edges to trim before processing (default is 0.0, valid values between 0 and <1)
            % obj.verbose     - More output info shown (false by default)
            % medFiltSize - The size of the filter to use for median filtering of the image (6 pixels by default)
            % polynomDetrendOrder - The order of the polynomial used to detrend row and column averages (default: 3)
            %
            %
            % Outputs
            % Returns number of microns per pixel along the rows and columns
            % NOTE: these values are currently based upon the rotated grid image. So if your image is scaled
            % very differently across the rows and columns and the grid wasn't imaged in an orientation close
            % that of the scan axes then you will get inaccurate values. Of course it is straightforward to
            % calculate the true microns per pixel along the scan axes, but so far we haven't needed to so the
            % function does not do this.
            %
            %
            %
            % PROTOCOL
            % We use copper EM grids of known pitch. We use part number 2145C from www.2spi.com/category/grids
            % These grids are listed as having:
            % - a pitch of 25 microns
            % - a hole width of 19 microns
            % - a bar width of 6 microns
            %
            %
            %
            % We remove one grid and place it on microscope slide. Seal it with a coverslip.
            % For measurement with a 2-photon microscope we will see fluorescence from the naked copper
            % grid at 920 nm. Use very low power. e.g. 3 mW. The grid should be oriented so that it's aligned
            % relatively closely with the scan axes. This function will attempt to rotate the grid so that it's
            % perpendicular with the scan axes, but we suggest you get it correctly aligned to within about 10
            % degrees (see note above). Make sure the grid is in focus and take and image. Feed this image to
            % this function.
            %
            %
            % Examples
            % The following are ways of obtaining a grid image directly from ScanImage
            % >> Grid2MicsPerPixel
            % >> Grid2MicsPerPixel([])
            % >> Grid2MicsPerPixel([],'medFiltSize',3)
            %
            % You can also feed in a specific grid image
            % >> someImage = imread('someImage.tiff');
            % >> Grid2MicsPerPixel(someImage)
            %
            % Requires the Stats Toolbox
            %
            % Rob Campbell, Basel Biozentrum, initial commit 2016



            % Attempt to get data from ScanImage
            if nargin<1 || isempty(inputIM)
                inputIM = obj.getCurrentImageFromScanImageAsArray;
                if isempty(inputIM)
                    fprintf(['\nUnable to get current image from ScanImage.\n', ...
                        'Please supply an image as an input argument.\n', ...
                        'See "help Grid2MicsPerPixel" for more information.\n'])
                    delete(obj)
                    return
                else
                    obj.scanImageConnected=true;
                end
            else
                obj.scanImageConnected=false;
            end

            params = inputParser;
            params.CaseSensitive = false;
            params.addParameter('gridPitch', 25, @(x) isnumeric(x) && isscalar(x));
            params.addParameter('cropProp', 0.0, @(x) isnumeric(x) && isscalar(x) && x>=0 && x<1);
            params.addParameter('verbose', false, @(x) islogical(x) || x==0 || x==1);
            params.addParameter('medFiltSize', 6, @(x) isnumeric(x) && isscalar(x));
            params.addParameter('polynomDetrendOrder', 3, @(x) isnumeric(x) && isscalar(x));

            params.parse(varargin{:});
            obj.gridPitch = params.Results.gridPitch;
            obj.verbose = params.Results.verbose;
            obj.cropProp = params.Results.cropProp;
            obj.polynomDetrendOrder = params.Results.polynomDetrendOrder;

            medFiltSize = params.Results.medFiltSize;
            obj.medFiltSize = [medFiltSize,medFiltSize];


            obj.prepareImageForDisplay(inputIM) %This needs running whenever a new image is loaded

            obj.createAndFocusFigWindow
            obj.buildFigure % THE MAIN WORKHORSE

        end % constructor


        function delete(obj)
            cellfun(@delete,obj.listeners)
            if ~isempty(obj.hFig)
                obj.hFig.delete
            end
        end % destructor


        % The following are methods the user might want to call
        function newGridFromSI(obj,~,~)
            % Get a new image from ScanImage, process, and display results
            % Run on button press
            inputIM = obj.getCurrentImageFromScanImageAsArray;
            if isempty(inputIM)
                return
            end
            obj.prepareImageForDisplay(inputIM) %This needs running whenever a new image is loaded

            obj.createAndFocusFigWindow
            obj.buildFigure
        end % newGridFromSI


        function applyCurrentPixelSizeToSI(obj,~,~)
            % Apply the average FOV size along rows and columns to ScanImage
            % Run on button press
            if isempty(obj.micsPix)
                return
            end
            mu = mean([obj.micsPix.rowFOV, obj.micsPix.colFOV]);
            sibridge.setObjectiveResolution(mu)
        end % applyCurrentPixelSizeToSI


        function returnData(obj,~,~)
            % Run on button press
            obj.printPixelSizeToScreen
            fprintf('Placing data in base workspace as "GRID_DATA"\n')
            assignin('base','GRID_DATA',obj.micsPix)
        end % returnData


        function savePDF(obj,~,~)
            % Save the current figure as a PDF to the desktop in a date-stamped folder
            saveDir = mpqc.tools.makeTodaysDataDirectory;
            fname = fullfile(saveDir,[datestr(now,'yyyy-mm-dd_HH-MM-SS'),'_grid.pdf']);
            obj.toggleButtonVisibility('off')
            print('-dpdf','-bestfit',fname)
            fprintf('Saved image to: %s\n',fname)
            obj.toggleButtonVisibility('on')
        end %savePDF


        function printPixelSizeToScreen(obj)
            fprintf('\n%0.3f mics/pix along columns (width=%0.1f microns)\n', ...
                obj.micsPix.micsPixCols, obj.micsPix.colFOV)
            fprintf('%0.3f mics/pix along rows (width=%0.1f microns)\n\n', ...
                obj.micsPix.micsPixRows, obj.micsPix.rowFOV)
        end % printPixelSizeToScreen

    end % methods


    % The following are hidden methods

    methods (Hidden)
        % These are in separate files
        bestAng = findGridAngle(obj,im)
        buildFigure(obj)
    end

    methods (Hidden)
        function createAndFocusFigWindow(obj)
            % Only create a plot window if one does not already exist
            % (want to avoid writing into existing windows that are doing other stuff)
            fig = findobj(0,'Tag',obj.figName);
            if isempty(fig)
                obj.hFig = figure;
                set(obj.hFig, 'Tag', obj.figName, 'Name', 'Grid measurement')
            else
                %Focus
                obj.hFig = fig;
                figure(fig)
                clf
            end
        end % createAndFocusFigWindow

        function prepareImageForDisplay(obj, inputIM)
            % crop, filter, and align the raw input image with axes as needed and populate the gridIm variable

            %Crop the image
            obj.origImage = double(inputIM);

            %Subtract offset
            tmp = imresize(obj.origImage,0.2);
            obj.origImage = obj.origImage - min(tmp(:)); % we want to store it with offset subtracted

            if obj.cropProp>0
                obj.cropPix=floor(size(obj.origImage)*obj.cropProp);
                obj.gridIm = obj.origImage(obj.cropPix:end-obj.cropPix, obj.cropPix:end-obj.cropPix);
            else
                obj.gridIm = obj.origImage;
            end

            %Filter the image to get rid of noise that can throw off the peak detection
            obj.gridIm = medfilt2(obj.gridIm,obj.medFiltSize);

            % Rotate image so it's square with axes
            obj.imRotatedAngle=obj.findGridAngle(obj.gridIm);

            obj.gridIm = imrotate(obj.gridIm,obj.imRotatedAngle,'crop') ;
            obj.gridIm(obj.gridIm==0)=nan;
        end % prepareImageForDisplay


        function h=peakFinder(obj,mu)
            % Find locations of peaks along vector, mu. Plots the results
            % Peaks are supposed to correspond to where the grating is
            %
            % Returns structure h with fields:
            % locs - locations of peaks
            % line - handles to line plot elements
            % peaks - handles to peak plot elements
            % micsPix - scalar defining the number of microns per pixel

            %Try to remove long-range trends
            mu = obj.detrendLine(mu);

            %Estimate how far apart the peaks are
            [~,indMax] = max(abs(fft(mu-mean(mu))));
            period = round(length(mu)/indMax);

            fprintf('Grid period is about %d pixels\n',period)

            [pks,locs]=findpeaks(mu,'minpeakheight',std(mu)*0.8,'minpeakdistance', round(period*0.9) );

            if isempty(pks)
              error('found no peaks\n')
            end
            h.locs=locs;

            h.line=plot(mu);
            hold on
            h.peaks=plot(locs,pks,'o');


            h.micsPix=obj.gridPitch/median(diff(locs));
            axis tight
        end %close peakFinder


        function out = detrendLine(obj,data)
            %detrend data using a polynomial
            data=data(:);

            x=1:length(data);
            x=x';

            [p,s,mu] = polyfit(x,data,obj.polynomDetrendOrder);
            f_y = polyval(p,x,[],mu);

            out = data-f_y;
        end


        function p = addLinesToImage(obj,h,axisToAdd,lineColor)
            % Overlay the calculated location of the grid lines onto the rotated image
            % This is to allow the user visually verify that all lines in the image have been identified
            % This method called by buildFigure
            hold(obj.hRotatedAx,'on')
            for ii=1:length(h.locs)
                thisL = h.locs(ii);
                if axisToAdd == 1
                    p(ii)=plot(obj.hRotatedAx, xlim(obj.hRotatedAx), [thisL,thisL]);
                elseif axisToAdd == 2
                    p(ii)=plot(obj.hRotatedAx, [thisL,thisL], ylim(obj.hRotatedAx));
                end
            end

            if length(p)>10
                lWidth=0.5;
            elseif length(p)<10 && length(p)>5;
                lWidth=1;
            else
                lWidth=2;
            end

            set(p,'linewidth',lWidth,'color',lineColor,'LineStyle','-');
        end %close addLinesToImage


        function siImage = getCurrentImageFromScanImageAsArray(obj)
            % Check if ScanImage is connected and extract from it the current
            % image as an array. Return this as an output argument.

            T=sibridge.getCurrentImage;
            if isempty(T)
                siImage=T;
                return
            end

            if length(T)>1
                fprintf('Averaging %d channels\n', length(T))
                siImage = mean(cat(3,T{:}),3);
            elseif length(T)==1
                siImage=T{1};
            end

            if obj.rotImage>0
                siImage = rot90(siImage,obj.rotImage);
            end
        end % getCurrentImageFromScanImageAsArray


        function toggleButtonVisibility(obj,onOff)
            % Set all on-screen buttons to be visible or not visible
            %
            % 'onOff' should be the string 'on' or the string 'off'

            obj.hButtonReturnData.Visible = onOff;
            obj.hButtonSavePDF.Visible = onOff;
            obj.hButtonNewIm.Visible = onOff;
            obj.hButtonApplyFOV.Visible = onOff;
        end %toggleButtonVisibility

    end
end % classdef

