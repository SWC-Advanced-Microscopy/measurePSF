function electrical_noise
    % Record electrical noise on all channels
    %
    % function mpqc.record.electrical_noise()
    %
    % Purpose
    % Record electrical noise with PMTs off on all channels. The function
    % automatically finds the number of possible channels and activates them all.
    %
    %
    % e.g.
    % >> mpqc.record.electrical_and_dark_noise
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2022


    % Connect to ScanImage using the linker class
    API = sibridge.silinker;


    % Create 'diagnostic' directory in the user's desktop
    saveDir = mpqc.tools.makeTodaysDataDirectory;
    if isempty(saveDir)
        return
    end


    %Record the state of all ScanImage settings we will change so we can change them back
    initialSettings = mpqc.tools.recordScanImageSettings(API);

    % Set all channels for saving
    API.saveAllChannels;

    %Apply common setting
    API.setZSlices(1)
    API.hSI.hBeams.powers=0; % set laser power to zero
    API.hSI.hStackManager.framesPerSlice=1;
    API.hSI.hRoiManager.pixelsPerLine=512;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hChannels.loggingEnable=true;

    % Set file name and save dir then acquire electrical noise
    API.turnOffAllPMTs; % Turn off PMTs
    pause(0.5)

    SETTINGS=mpqc.settings.readSettings;
    fileStem = sprintf('%s_electrical_noise__%s', ...
        SETTINGS.microscope.name, ...
        datestr(now,'yyyy-mm-dd_HH-MM-SS'));

    API.hSI.hScan2D.logFileStem=fileStem;
    API.hSI.hScan2D.logFilePath=saveDir;
    API.hSI.hScan2D.logFileCounter=1;

    API.acquireAndWait;


    % Report saved file location and copy mpqc settings there
    postAcqTasks(saveDir,fileStem)

    % Return ScanImage to the state it was in before we started.
    mpqc.tools.reapplyScanImageSettings(API,initialSettings);
    API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;
    API.turnOffAllPMTs;

end
