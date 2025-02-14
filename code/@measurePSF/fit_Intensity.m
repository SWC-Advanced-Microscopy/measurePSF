function [fitresult, gof] = fit_Intensity(obj,Y,micsPerPix,numberOfTerms)
    % Fit PSF intensity profile with a Gaussian
    %
    % function [fitresult, gof] = fit_Intensity(Y,micsPerPix,numberOfTerms)
    %
    % Purpose
    % This is a measurePSF helper function.
    %
    %
    % Inputs
    %  Y - the vector intensities for this PSF cross-section
    %  micsPerPix - the number of microns per pixel (set to 1
    %            if using this function to determine the index of the peak)
    %  numberOfTerms - number of terms in the Gaussian. Use 1 for a regular
    %               Gaussian. 2 if kurtosis of the raw data seem high.
    %               By default we use the value in obj.zFitOrder
    %
    % Outputs
    %  fitresult - a fit object representing the fit.
    %  gof - structure with goodness-of fit info.
    %
    %  See also FIT, CFIT, SFIT.
    %
    % Rob Campbell, Basel Biozentrum, initial commit 2016

    obj.reportMethodEntry

    v=ver;
    if isempty(strmatch('Curve Fitting', {v.Name}))
        fprintf('*** No curve fitting toolbox, not returning a fit ***\n')
        fitresult=[];
        gof=[];
        return
    end

    if nargin<4
        numberOfTerms=obj.zFitOrder;
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
