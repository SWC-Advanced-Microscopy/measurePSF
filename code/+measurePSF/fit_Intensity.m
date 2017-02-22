function [fitresult, gof] = fit_Intensity(Y,micsPerPix,numberOfTerms)
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
