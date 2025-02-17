function gainsToTest = getPMTGainsToTest(numGains)
    % Generate a vector of PMT gains to test based on the PMT type
    %
    % Purpose
    % Records of the standard source in particular but perhaps also lens paper are
    % done over a range of gains. This function returns a set of gain values to record
    % based upon the PMT type. If the max control voltage is under 2V then it is assumed
    % we have a GaAsP, as those have max control voltage of around 0.9 to 1.5V. Also, if
    % the max voltage is 1 or 100 then it's also likely to be a GaAsP.
    % This function is shared across recording functions in case we need to synchronize
    % the gains at which data are acquired.
    %
    %
    % Inputs
    % numGains - (optional 12 by default) this is the number of gains to test.
    %            If numGains is empty or <0 then the default number of gains is used.
    %
    % Outputs
    % gainsToTest - a matrix where rows are different PMTs and columns are gains.
    %
    % % TODO ! include example output
    %
    % Rob Campbell, SWC AMF, initial commit 2025


    if nargin<1 || isempty(numGains) || numGains<0
        numGains=4;
    end

    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    if API.linkSucceeded == false
        return
    end


    % Get gains to test for each PMT (PMTs can be GaAsp or multi-alkali and this
    % is taken into account here)
    gainsToTest = [];
    for ii=1:length(API.hSI.hPmts.hPMTs)
        gainsToTest = [gainsToTest; generateGainsForPMT(API.hSI.hPmts.hPMTs{ii})];
    end



    function tPMTgains = generateGainsForPMT(hPMT)
        if hPMT.pmtSupplyRange_V(2) <= 100 || hPMT.aoRange_V(2) <= 2
            isMultiAlkali = false;
        else
            isMultiAlkali = true;
        end

        if isMultiAlkali
            tPMTgains = [0,linspace(500,725,numGains)];
        else
            maxV = hPMT.pmtSupplyRange_V(2);
            tPMTgains = [0, linspace(maxV*0.55,maxV*0.8,numGains)];
        end

        tPMTgains = round(tPMTgains);
    end % generateGainsForPMT

end
