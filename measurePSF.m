function varargout=measurePSF(PSFstack)
% Display PSF and measure its size in X, Y, and Z
%
% Purpose
% Fit and display a PSF
%
% INPUTS
% PSFstack  - a 3-D array (imagestack). First layer should be that nearest the objective


micsPerPixelXY = 0.04;
micsPerPixelZ = 0.5;

PSFstack = double(PSFstack);

%Estimate the center of the PSF in Z by finding the brightest point

%Clean up the PSF because we're using max
DS = imresize(PSFstack,0.25); 
for ii=1:size(DS,3)
	DS(:,:,ii) = conv2(DS(:,:,ii),ones(2),'same');
end
Z = max(squeeze(max(DS))); 


z=max(squeeze(max(DS)));
[f,g] = fit_Intensity(z,1);
psfCenterInZ = round(f.b1);



midZ=round(size(PSFstack,3)/2);


clf

%PSF at mid-point
axes('Position',[0.03,0.07,0.4,0.4])
maxZplane = PSFstack(:,:,psfCenterInZ);
imagesc(maxZplane)

text(size(PSFstack,1)*0.025,...
	size(PSFstack,2)*0.04,...
	sprintf('PSF center at slice #%d',psfCenterInZ),...
	'color','w','VerticalAlignment','top') 

%sort out the axes
showAxesInMainPSFplot=0;
if showAxesInMainPSFplot
	Xtick = linspace(1,size(maxZplane,1),8);
	Ytick = linspace(1,size(maxZplane,2),8);
	set(gca,'XTick',Xtick,'XTickLabel',round(Xtick*micsPerPixelXY,2),...
			'YTick',Ytick,'YTickLabel',round(Ytick*micsPerPixelXY,2));
else
	set(gca,'XTick',[],'YTick',[])
end

%Find the center of the bead in X and Y by fitting gaussians along these dimensions
f = fit_Intensity(max(maxZplane,[],1),1);
psfCenterInX = round(f.b1);

f = fit_Intensity(max(maxZplane,[],2),1);
psfCenterInY = round(f.b1);

hold on
plot(xlim,[psfCenterInY,psfCenterInY],'--w')
plot([psfCenterInX,psfCenterInX],ylim,'--w')
hold off


%The slice along the rows  (fit along the right side of the X/Y PSF)
axes('Position',[0.435,0.07,0.1,0.4])
yvals = maxZplane(:,psfCenterInX);
x=(1:length(yvals))*micsPerPixelXY;
fitX = fit_Intensity(yvals,micsPerPixelXY);
plotCrossSectionAndFit(x,yvals,fitX,micsPerPixelXY/2,1);
set(gca,'XTickLabel',[])


%The slice down the columns (fit above the X/Y psf)
axes('Position',[0.03,0.475,0.4,0.1])
yvals = maxZplane(psfCenterInY,:);
x=(1:length(yvals))*micsPerPixelXY;
fitY = fit_Intensity(yvals,micsPerPixelXY);
plotCrossSectionAndFit(x,yvals,fitY,micsPerPixelXY/2);
set(gca,'XTickLabel',[])


%So now we can slice the PSF in Z along the X and Y maxima 

%PSF in Z/Y
axes('Position',[0.03,0.6,0.4,0.1])
PSF_ZY=squeeze(PSFstack(psfCenterInY,:,:));
imagesc(PSF_ZY)

Xtick = linspace(1,size(PSF_ZY,2),8);
Ytick = linspace(1,size(PSF_ZY,1),3);

set(gca,'XAxisLocation','Top',...
		'XTick',[],...
		'YTick',Ytick,'YTickLabel',round(Ytick*micsPerPixelXY,2));

t=text(1,1,	sprintf('PSF in Z/Y'), 'Color','w','VerticalAlignment','top');

axes('Position',[0.03,0.705,0.4,0.1])
maxPSF_ZY = max(PSF_ZY,[],1);
fitZY = fit_Intensity(maxPSF_ZY, micsPerPixelZ,2);
x = (1:length(maxPSF_ZY))*micsPerPixelZ;
plotCrossSectionAndFit(x,maxPSF_ZY,fitZY,micsPerPixelZ/4);
set(gca,'XAxisLocation','Top')






%PSF in Z/X (on the right)
axes('Position',[0.56,0.07,0.1,0.4])
PSF_ZX=squeeze(PSFstack(:,psfCenterInX,:));
PSF_ZX=rot90(PSF_ZX,3);
imagesc(PSF_ZX)


Xtick = linspace(1,size(PSF_ZX,2),3);
Ytick = linspace(1,size(PSF_ZX,1),8);


set(gca,'YAxisLocation','Right',...
		'XTick',Xtick,'XTickLabel',round(Xtick*micsPerPixelXY,2),...
		'YTick',[])

t=text(1,1,	sprintf('PSF in Z/X'), 'Color','w','VerticalAlignment','top');

axes('Position',[0.665,0.07,0.1,0.4])
maxPSF_ZX = max(PSF_ZX,[],2);
fitZX = fit_Intensity(maxPSF_ZX, micsPerPixelZ,2);
x = (1:length(maxPSF_ZX))*micsPerPixelZ;
plotCrossSectionAndFit(x,maxPSF_ZX,fitZX,micsPerPixelZ/4,1);
set(gca,'XAxisLocation','Top')


%Finally, we add a plot with a scroll-bar so we can view the PSF as desires
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
			'Callback', @(~,~) updateUserSelected(PSFstack) ) ;

title(sprintf('Slice #%d',psfCenterInZ))


if nargout>0
	OUT.slider = slider;
	OUT.fitY = fitY;
	OUT.fitX = fitX;
	OUT.PSF_ZX = PSF_ZX;
	OUT.PSF_ZY = PSF_ZY;
	varargout{1} = OUT;
end

function [fitresult, gof] = fit_Intensity(Y,micsPerPix,numberOfTerms)
	%  Data for 'Z_FIT' fit:
	%      Y Output: Z
	%  Output:
	%      fitresult : a fit object representing the fit.
	%      gof : structure with goodness-of fit info.
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
	FWHM = (length(yvals)-halfMaxInd)*fitRes;


	%Plot
	hold on
	%The FWHM area
	deltaIndVals  = length(yvals)-halfMaxInd ;%number of index values between the peak and the FWHM point
	inds = (maxInd-deltaIndVals):(maxInd+deltaIndVals);
	p(1)=area(fitX(inds),fitY(inds));
	set(p,'FaceColor','k','EdgeColor','none','FaceAlpha',0.15)

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
	grid

	%Add ticks such that the peak has a tick mark that we will label as zero	
	stepSize  = (fitX(end)-fitX(1))/11; %to divide up the fit
	xAtMax = fitX(length(yvals));

	xtick = unique([xAtMax:-stepSize:fitX(1),xAtMax:stepSize:fitX(end)]);


	set(gca,'YTickLabel',[],'XTick',xtick,'XTickLabel', round(xtick-xAtMax,2))


function updateUserSelected(PSFstack)
	Hax=findobj('Tag','userSelected');
	Hslider = findobj('Tag','DepthSlider');


	slice = round(Hslider.Value);
	set(Hax,'CData',PSFstack(:,:,slice))
	caxis([min(PSFstack(:)), max(PSFstack(:))])

	title(sprintf('Slice #%d',slice))