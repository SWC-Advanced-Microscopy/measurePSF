function OUT=updateXYfits(obj)
    % Updates the X/Y bead fits on either side of the bottom/left plot
    %
    % Rob Campbell, Basel Biozentrum, initial commit 2016

    %The cross-section sliced along the rows (the fit shown along the right side of the X/Y PSF)
    axes(obj.hxSectionRowsAx);
    cla %TODO -- This isn't great, but it works (see below)
    yvals = obj.maxZplane(:,obj.psfCenterInX);
    x=(1:length(yvals))*obj.micsPerPixelXY;
    fitX = obj.fit_Intensity(yvals,obj.micsPerPixelXY);
    OUT.XYrows.FWHM = obj.plotCrossSectionAndFit(x,yvals,fitX,obj.micsPerPixelXY/2,1,'YX'); %TODO -- Would be best to change plot object props and not CLA each time
    X.xVals=x;
    X.yVals=yvals;
    set(obj.hxSectionRowsAx,'XTickLabel',[])

    %Suppress title with FWHM estimate if no mics per pixel was provided
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
    OUT.XYcols.FWHM = obj.plotCrossSectionAndFit(x,yvals,fitY,obj.micsPerPixelXY/2,0,'XY');
    Y.xVals=x;
    Y.yVals=yvals;
    set(obj.hxSectionColsAx,'XTickLabel',[])

    %Suppress title with FWHM estimate if no mics per pixel was provided
    if ~obj.reportFWHMxy
        title('XY: mics/pixel missing')
    end
    obj.PSFstats.Y.fit = fitY;
    obj.PSFstats.Y.data = Y;

end % Close updateXYfits
