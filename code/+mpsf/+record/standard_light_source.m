function standard_light_source()
    % Record response to the standard light source on all four channels
    %
    % function record.standard_light_source()
    %
    % Purpose
    % Runs through a series of gain values to record signals from the 
    % standard source. Places data in their own directory, as there is 
    % one file per gain. 
    % 
    %
    % Rob Campbell, SWC 2022


    fprintf('Place light source under objective and turn off enclosure lights then press return\n')
    pause

    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    API.hSI.hChannels.channelSave = 1:4;


    % Create 'diagnostic' directory in the user's desktop
    saveDir = mpsf.tools.makeTodaysDataDirectory;
    if isempty(saveDir)
        return
    end

    % Determine the name of the files we will be saving and 
    % make a sub-directory into which to store the data
    SETTINGS=mpsf.settings.readSettings;
    fileStem = sprintf('%s_standard_light_source__%s', ...
        SETTINGS.microscope.name, ...
        datestr(now,'yyyy-mm-dd_HH-MM-SS'));

    lightSourceDir = fullfile(saveDir,fileStem);
    mkdir(lightSourceDir)

    %Record the state of all ScanImage settings we will change so we can change them back
    settings = mpsf.tools.recordScanImageSettings(API);


    %Apply common setting
    API.setZSlices(1)
    API.hSI.hBeams.powers=0; % set laser power to zero
    API.hSI.hStackManager.framesPerSlice=1; % We will record multiple frames
    API.hSI.hRoiManager.pixelsPerLine=256;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hChannels.loggingEnable=true;


    % Get gains to test for each PMT (remember PMTs can be GaAsp or multi-alkali)
    gainsToTest = [];
    for ii=1:length(API.hSI.hPmts.hPMTs)
        gainsToTest = [gainsToTest; getPMTGainsToTest(API.hSI.hPmts.hPMTs{ii})];
    end
    
    API.turnOnPMTs; % Turn off PMTs
    pause(0.5)

    % Set the file name
    API.hSI.hScan2D.logFileStem=fileStem;
    API.hSI.hScan2D.logFilePath=lightSourceDir;
    API.hSI.hScan2D.logFileCounter=1;

    API.hSI.acqsPerLoop=length(gainsToTest);
    API.hSI.extTrigEnable=true;

    API.hSI.startLoop;
    for ii=1:length(gainsToTest)
        % Set file name and save dir
        API.setPMTgains(gainsToTest(:,ii)); % Set gain
        pause(0.5) % Out of abundance of caution

        API.hSI.hScan2D.trigIssueSoftwareAcq;
        pause(0.5) % Images will be acquired in under a second
    end

    API.turnOffPMTs; % Turn off PMTs


    mpsf.tools.reapplyScanImageSettings(API,settings);

    API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;

    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)



function gainsToTest = getPMTGainsToTest(hPMT)
    % If the max control voltage is under 2V then it must be a 
    % GaAsP, as those have max control voltage of around 0.9 to 1.5V
    %
    % Also, if the max voltage is 1 or 100 then it's also likely to be a GaAsP


    if hPMT.pmtSupplyRange_V(2) <= 100 || hPMT.aoRange_V(2) <= 2
        isMultiAlkali = false;
    else
        isMultiAlkali = true;
    end

    numGains=12;
    if isMultiAlkali
        gainsToTest = [0,linspace(400,750,numGains)];
    else
        maxV = hPMT.pmtSupplyRange_V(2);
        gainsToTest = [0, linspace(maxV*0.33,maxV*0.8,numGains)];
    end
