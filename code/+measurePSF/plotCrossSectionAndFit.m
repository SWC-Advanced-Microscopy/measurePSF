function [FWHM,p] = plotCrossSectionAndFit(x,y,fitObj,fitRes,flipAxes)
    % Used by measurePSF to plot the fit cross-sections
    %
    %
    % x - x data
    % y - y data
    % fitObj - the fit object produced by measurePSF.fit_Intensity that is associated with these data
    % fitRes - the resolution in microns of the fitted curve. This is used to obtain the FWHM
    % flipAxes - set to true to flip x/y axes for the plots long the right. 
    
    if nargin<5
        flipAxes = 0;
    end

    %Generate x data 
    fitX = x(1):fitRes:x(end);
    fitY = feval(fitObj,fitX); 


    %calculate the FWHM
    halfMax = (fitObj.a1)/2;


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
    if verLessThan('matlab','8.6')
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

    set(gca,'YTickLabel',[],'XTick',xtick,'XTickLabel', measurePSF.round(xtick-xAtMax,2))

