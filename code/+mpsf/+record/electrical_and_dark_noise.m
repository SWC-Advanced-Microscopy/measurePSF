function electrical_and_dark_noise()
    % Record electrical noise and dark noise on all four channels
    %
    % function record.electrical_and_dark_noise()
    %
    % CAUTION: will turn on PMTs! ENSURE THERE IS NO LIGHT SOURCE OR SAMPLE!
    %
    % e.g.
    % >> mpsf.record.electrical_and_dark_noise
    %
    %
    % Rob Campbell, SWC 2022


    fprintf('Remove sample and ensure enclosure is dark then press return\n')
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
    initialSettings = mpsf.tools.recordScanImageSettings(API);


    %Apply common setting
    API.setZSlices(1)
    API.hSI.hBeams.powers=0; % set laser power to zero
    API.hSI.hStackManager.framesPerSlice=1;
    API.hSI.hRoiManager.pixelsPerLine=512;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hChannels.loggingEnable=true;

    % Set file name and save dir then acquire electrical noise
    API.turnOffPMTs; % Turn off PMTs
    pause(0.5)

    SETTINGS=mpsf.settings.readSettings;
    fileStem = sprintf('%s_electrical_noise__%s', ...
        SETTINGS.microscope.name, ...
        datestr(now,'yyyy-mm-dd_HH-MM-SS'));

    API.hSI.hScan2D.logFileStem=fileStem;
    API.hSI.hScan2D.logFilePath=saveDir;
    API.hSI.hScan2D.logFileCounter=1;

    API.acquireAndWait;


    % Set file name and save dir then acquire dark noise
    API.turnOnPMTs;
    volts=650;
    API.setPMTgains(volts);
    pause(0.5)

    SETTINGS=mpsf.settings.readSettings;
    fileStem = sprintf('%s_dark_noise__%dV__%s', ...
        SETTINGS.microscope.name, ...
        volts, ...
        datestr(now,'yyyy-mm-dd_HH-MM-SS'));

    API.hSI.hScan2D.logFileStem=fileStem;
    API.hSI.hScan2D.logFilePath=saveDir;
    API.hSI.hScan2D.logFileCounter=1;

    API.acquireAndWait;


    % Report saved file location and copy mpsf settings there
    postAcqTasks(saveDir,fileStem)

    % Nested cleanup function that will return ScanImage to its original settings. The
    % cleanup function was defined near the top of the file.
    function cleanupAfterAcquisition
        % Return ScanImage to the state it was in before we started.
        mpsf.tools.reapplyScanImageSettings(API,initialSettings);
        API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;
        API.turnOffPMTs;
    end

end
