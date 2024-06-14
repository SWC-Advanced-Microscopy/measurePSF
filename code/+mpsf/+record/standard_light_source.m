function standard_light_source()
    % Record response to the standard light source on all four channels
    %
    % function record.standard_light_source()
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


    % Loop through a range of gains
    gainsToTest = [0,400:50:700];

    API.turnOnPMTs; % Turn off PMTs
    pause(0.5)

    SETTINGS=mpsf.settings.readSettings;
    for ii=1:length(gainsToTest)
        % Set file name and save dir
        API.setPMTgains(gainsToTest(ii)); % Set gain

        fileStem = sprintf('%s_standard_light_source__%dV__%s', ...
            SETTINGS.microscope.name, ...
            gainsToTest(ii), ...
            datestr(now,'yyyy-mm-dd_HH-MM-SS'));

        API.hSI.hScan2D.logFileStem=fileStem;
        API.hSI.hScan2D.logFilePath=saveDir;
        API.hSI.hScan2D.logFileCounter=1;

        API.acquireAndWait;
    end

    API.turnOffPMTs; % Turn off PMTs


    mpsf.tools.reapplyScanImageSettings(API,settings);

    API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;

    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)

