function [FWHM,p] = plotCrossSectionAndFit(obj,x,y,fitObj,fitRes,flipAxes,plotAxStr)
    % Used by measurePSF to plot the fit cross-sections
    %
    %
    % INPUTS
    % x - x data
    % y - y data
    % fitObj - the fit object produced by measurePSF.fit_Intensity that is associated with these data
    % fitRes - the resolution in microns of the fitted curve. This is used to obtain the FWHM
    % flipAxes - set to true to flip x/y axes for the plots long the right.
    % plotAxStr - a string to indicate which axes are being plotted (e.g. 'XZ'). This is added to the
    %             title string.
    %
    % OUTPUTS (returns empty fitObj is empty)
    % FWHM - the full-width-half-max
    % p - plot handle of the fit
    %
    %
    % Rob Campbell, Basel Biozentrum, initial commit 2016

    if isempty(fitObj)
        FWHM = [];
        p=[];
        return
    end
    if nargin<6
        flipAxes = 0;
    end
    if nargin<7
        plotAxStr='';
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


    %The FWHM area
    deltaIndVals  = length(yvals)-halfMaxInd; % Number of index values between the peak and the FWHM point
    inds = (maxInd-deltaIndVals):(maxInd+deltaIndVals);

    if any(inds>length(fitX))
        FWHM = [];
        p=[];
        fprintf('Plotting of FWHM curve failed in measurePSF.plotCrossSectionAndFit -- Values out of range.\n')
        return
    end


    %Plot
    hold on

    p(1)=area(fitX(inds),fitY(inds));

    set(p,'FaceColor','r','EdgeColor','none')

    if verLessThan('matlab','8.6')
        set(p,'FaceColor',[1.0,0.85,0.85]);
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


    title(sprintf('%s FWHM: %0.2f \\mum',plotAxStr,FWHM))

    axis tight
    grid on

    %Add ticks such that the peak has a tick mark that we will label as zero
    stepSize  = (fitX(end)-fitX(1))/11; %to divide up the fit
    xAtMax = fitX(length(yvals));

    xtick = unique([xAtMax:-stepSize:fitX(1),xAtMax:stepSize:fitX(end)]);

    set(gca,'YTickLabel',[],'XTick',xtick, ...
        'XTickLabel', round(xtick-xAtMax,2), ...
        'XLim', [min(x),max(x)])
