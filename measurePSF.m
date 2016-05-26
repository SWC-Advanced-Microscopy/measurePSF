function varargout=measurePSF(PSFstack,micsPerPixelXY,micsPerPixelZ,varargin)
% Display PSF and measure its size in X, Y, and Z
%
% function varargout=measurePSF(PSFstack,micsPerPixelXY,micsPerPixelZ,maxIntensityInZ)
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
% maxIntensityInZ - [false by default] if true we use the max intensity projection
%                   for the Z PSFs. This is likely necessary if the PSF is very tilted.
% zFitOrder - [1 by default]. Number of gaussians to use for the fit of the Z PSF
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
% Curve-Fitting Toolbox

if nargin<1
    help(mfilename)
    P=load('PSF');
    PSFstack = P.PSF;
    micsPerPixelXY=0.05;
    micsPerPixelZ=0.500;
end

params = inputParser;
params.CaseSensitive = false;
params.addParamValue('maxIntensityInZ', 1, @(x) islogical(x) || x==0 || x==1);
params.addParamValue('zFitOrder', 1, @(x) isnumeric(x) && isscalar(x));

params.parse(varargin{:});

maxIntensityInZ = params.Results.maxIntensityInZ;
zFitOrder = params.Results.zFitOrder;



% Step One
%
% Estimate the slice that contains center of the PSF in Z by finding the brightest point.
PSFstack = double(PSFstack);
PSFstack = PSFstack - median(PSFstack(:)); %subtract the baseline because the Gaussian fit doesn't have an offset parameter

%Clean up the PSF because we're using max
DS = imresize(PSFstack,0.25); 
for ii=1:size(DS,3)
    DS(:,:,ii) = conv2(DS(:,:,ii),ones(2),'same');
end
Z = max(squeeze(max(DS))); 

z=max(squeeze(max(DS)));
f = fit_Intensity(z,1); 
psfCenterInZ = round(f.b1);

if psfCenterInZ > size(PSFstack,3) || psfCenterInZ<1
    fprintf('PSF center in Z estimated as slice %d. That is out of range. PSF stack has %d slices\n',...
        psfCenterInZ,size(PSFstack,3))
    return
end

midZ=round(size(PSFstack,3)/2); %The calculated mid-point of the PSF stack



%Plot the mid-point of the stack
clf

%PSF at mid-point
axes('Position',[0.03,0.07,0.4,0.4])
maxZplane = PSFstack(:,:,psfCenterInZ);
imagesc(maxZplane)

text(size(PSFstack,1)*0.025,...
    size(PSFstack,2)*0.04,...
    sprintf('PSF center at slice #%d',psfCenterInZ),...
    'color','w','VerticalAlignment','top') 


%Optionally, show the axes. Right now, I don't think we want this at all so it's not an input argument 
showAxesInMainPSFplot=0;
if showAxesInMainPSFplot
    Xtick = linspace(1,size(maxZplane,1),8);
    Ytick = linspace(1,size(maxZplane,2),8);
    set(gca,'XTick',Xtick,'XTickLabel',roundSig(Xtick*micsPerPixelXY,2),...
            'YTick',Ytick,'YTickLabel',roundSig(Ytick*micsPerPixelXY,2));
else
    set(gca,'XTick',[],'YTick',[])
end



% Step Two
%
% Find the center of the bead in X and Y by fitting gaussians along these dimensions.
% We will use these values to show cross-sections of it along X and Y at the level of the image plotted above
f = fit_Intensity(max(maxZplane,[],1),1);
psfCenterInX = round(f.b1);

f = fit_Intensity(max(maxZplane,[],2),1);
psfCenterInY = round(f.b1);

%Add lines to the main X/Y plot showing where we are slicing it to take the cross-sections
hold on
plot(xlim,[psfCenterInY,psfCenterInY],'--w')
plot([psfCenterInX,psfCenterInX],ylim,'--w')
hold off


%The cross-section sliced along the rows (the fit shown along the right side of the X/Y PSF)
axes('Position',[0.435,0.07,0.1,0.4])
yvals = maxZplane(:,psfCenterInX);
x=(1:length(yvals))*micsPerPixelXY;
fitX = fit_Intensity(yvals,micsPerPixelXY,1);
plotCrossSectionAndFit(x,yvals,fitX,micsPerPixelXY/2,1);
X.xVals=x;
X.yVals=yvals;
set(gca,'XTickLabel',[])


%The cross-section sliced down the columns (fit shown above the X/Y PSF)
axes('Position',[0.03,0.475,0.4,0.1])
yvals = maxZplane(psfCenterInY,:);
x=(1:length(yvals))*micsPerPixelXY;
fitY = fit_Intensity(yvals,micsPerPixelXY);
plotCrossSectionAndFit(x,yvals,fitY,micsPerPixelXY/2);
Y.xVals=x;
Y.yVals=yvals;
set(gca,'XTickLabel',[])



% Step Three
%
% We now obtain images showing the PSF's extent in Z
% We do this by taking maximum intensity projections or slices through the maximum
axes('Position',[0.03,0.6,0.4,0.1])


%PSF in Z/Y (panel above)
if maxIntensityInZ
    PSF_ZY=squeeze(max(PSFstack,[],1));
else
    PSF_ZY=squeeze(PSFstack(psfCenterInY,:,:));
end

imagesc(PSF_ZY)

Ytick = linspace(1,size(PSF_ZY,1),3);
set(gca,'XAxisLocation','Top',...
        'XTick',[],...
        'YTick',Ytick,'YTickLabel',roundSig(Ytick*micsPerPixelXY,2));

text(1,1,sprintf('PSF in Z/Y'), 'Color','w','VerticalAlignment','top');

%This is the fitted Z/Y PSF with the FWHM
axes('Position',[0.03,0.705,0.4,0.1])
maxPSF_ZY = max(PSF_ZY,[],1);
fitZY = fit_Intensity(maxPSF_ZY, micsPerPixelZ,zFitOrder);
x = (1:length(maxPSF_ZY))*micsPerPixelZ;
[OUT.ZY.FWHM,OUT.ZY.fitPlot_H] = plotCrossSectionAndFit(x,maxPSF_ZY,fitZY,micsPerPixelZ/4);
set(gca,'XAxisLocation','Top')




%PSF in Z/X (panel on the right on the right)
axes('Position',[0.56,0.07,0.1,0.4])
if maxIntensityInZ
    PSF_ZX=squeeze(max(PSFstack,[],2));
else
    PSF_ZX=squeeze(PSFstack(:,psfCenterInX,:));
end

PSF_ZX=rot90(PSF_ZX,3);
imagesc(PSF_ZX)

Xtick = linspace(1,size(PSF_ZX,2),3);
set(gca,'YAxisLocation','Right',...
        'XTick',Xtick,'XTickLabel',roundSig(Xtick*micsPerPixelXY,2),...
        'YTick',[])

text(1,1,sprintf('PSF in Z/X'), 'Color','w','VerticalAlignment','top');

%This is the fitted Z/X PSF with the FWHM
axes('Position',[0.665,0.07,0.1,0.4])
maxPSF_ZX = max(PSF_ZX,[],2);
fitZX = fit_Intensity(maxPSF_ZX, micsPerPixelZ,zFitOrder);
x = (1:length(maxPSF_ZX))*micsPerPixelZ;
[OUT.ZY.FWHM, OUT.ZX.fitPlot_H] = plotCrossSectionAndFit(x,maxPSF_ZX,fitZX,micsPerPixelZ/4,1);
set(gca,'XAxisLocation','Top')



% Step Four
%
% Finally, we add a plot with a scroll-bar so we can view the PSF as desires
axes('Position',[0.5,0.55,0.4,0.4])
userSelected=imagesc(maxZplane);
set(userSelected,'Tag','userSelected')
box on
set(gca,'XTick',[],'YTick',[])

slider = uicontrol('Style','Slider', ...
            'Units','normalized',...
            'Position',[0.9,0.55,0.02,0.4],...
            'Min',1,...
            'Max',size(PSFstack,3),...
            'Value',psfCenterInZ,...
            'Tag','DepthSlider',...
            'Callback', @(~,~) updateUserSelected(PSFstack,psfCenterInZ,micsPerPixelZ) ) ;

title(sprintf('Slice #%d',psfCenterInZ))


if nargout>0
    OUT.slider = slider;
    OUT.Y.fit  = fitY;
    OUT.Y.data  = Y;
    OUT.X.fit  = fitX;
    OUT.X.data  = X;
    OUT.ZY.fit = fitZY;
    OUT.ZX.fit = fitZY;
    OUT.ZX.im = PSF_ZX;
    OUT.ZY.im = PSF_ZY;
    varargout{1} = OUT;
end



function [fitresult, gof] = fit_Intensity(Y,micsPerPix,numberOfTerms)
    %  Fit PSF intensity profile with a Gaussian
    %
    % Inputs
    %  Y - the vector intensities for this PSF cross-section
    %  micsPerPix - the number of microns per pixel (set to 1 
    %            if using this function to determine the index of the peak)
    %  numberOfTerms - number of terms in the Gaussian. Use 1 for a regular 
    %               Gaussian. 2 if kurtosis of the raw data seem high.
    %
    %
    % Outputs
    %  fitresult - a fit object representing the fit.
    %  gof - structure with goodness-of fit info.
    %
    %  See also FIT, CFIT, SFIT.

    if nargin<3
        numberOfTerms=1;
    end

    Y = Y(:);
    X =  (1:length(Y))*micsPerPix;
    X = X(:);

    [xData, yData] = prepareCurveData(X,Y);

    % Set up fittype and options.
    ft = fittype(['gauss',num2str(numberOfTerms)]);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';


    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );

function [FWHM,p] = plotCrossSectionAndFit(x,y,fitObj,fitRes,flipAxes)
    % Used to plot the fit cross-sections
    %
    % x - x data
    % y - y data
    % fitObj - the fit object produced by fit_Intensity that is associated with these data
    % fitRes - the resolution in microns of the fitted curve. This is used to obtain the FWHM
    % flipAxes - set to true to flip x/y axes for the plots long the right. 
    
    if nargin<5
        flipAxes = 0;
    end
    %Generate x data 
    fitX = x(1):fitRes:x(end);
    fitY = feval(fitObj,fitX); 

    %calculate the FWHM
    halfMax = fitObj.a1/2;


    %Take just one side of the curve
    maxInd=find(max(fitY)==fitY);
    yvals = fitY(1:maxInd);

    [~,halfMaxInd]=min(abs(yvals-halfMax));
    FWHM = (length(yvals)-halfMaxInd)*fitRes*2;


    %Plot
    hold on
    %The FWHM area
    deltaIndVals  = length(yvals)-halfMaxInd ;%number of index values between the peak and the FWHM point
    inds = (maxInd-deltaIndVals):(maxInd+deltaIndVals);
    p(1)=area(fitX(inds),fitY(inds));

    set(p,'FaceColor','k','EdgeColor','none')
    if verLessThan('matlab','8.4')
        set(p,'FaceColor',[0.8,0.8,0.8]);
    else
        set(p,'FaceAlpha',0.15);
    end
    %The fit
    p(2)=plot(fitX,fitY,'-','linewidth',2,'color',[1,0.5,0.5]);

    %The raw data
    p(3)=plot(x,y,'k.');
    hold off

    if flipAxes
        view(90,90) % flip graph onto its side
    end

    
    title(sprintf('FWHM: %0.2f \\mum',FWHM))

    axis tight
    grid on

    %Add ticks such that the peak has a tick mark that we will label as zero    
    stepSize  = (fitX(end)-fitX(1))/11; %to divide up the fit
    xAtMax = fitX(length(yvals));

    xtick = unique([xAtMax:-stepSize:fitX(1),xAtMax:stepSize:fitX(end)]);

    set(gca,'YTickLabel',[],'XTick',xtick,'XTickLabel', roundSig(xtick-xAtMax,2))


function updateUserSelected(PSFstack,psfCenterInZ,micsPerPixelZ)
    % Runs when the user moves the slider
    Hax=findobj('Tag','userSelected');
    Hslider = findobj('Tag','DepthSlider');

    thisSlice = round(get(Hslider,'Value'));
    set(Hax,'CData',PSFstack(:,:,thisSlice))

    caxis([min(PSFstack(:)), max(PSFstack(:))])

    title(sprintf('Slice #%d %0.2f \\mum', thisSlice, (psfCenterInZ-thisSlice)*micsPerPixelZ ))


function out = roundSig(in,sigFig)
    % Needed for earlier MATLAB releases where round doesn't have a
    % a second input argument
    if nargin<2
        sigFig=1;
    end
    out = round(in * 10*sigFig)/(10*sigFig);


