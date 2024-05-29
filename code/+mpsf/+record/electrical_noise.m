function electrical_noise()
    % Record electrical noise on all four channels
    %
    % function record.electrical_noise()
    %
    %
    % Rob Campbell, SWC 2022

  

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

    % TODO -- bug. If there are not four PMTs this will return an error
    API.turnOffPMTs; % Turn off PMTs
    pause(0.5)

    %Apply common setting
    API.setZSlices(1)

    API.hSI.hStackManager.framesPerSlice=1; % We will record multiple frames
    API.hSI.hRoiManager.pixelsPerLine=512;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hChannels.loggingEnable=true;


    % Set file name and save dir
    SETTINGS=mpsf.settings.readSettings;
    fileStem = sprintf('%s_electrical_noise__%s', ...
        SETTINGS.microscope.name, ...
        datestr(now,'yyyy-mm-dd_HH-MM-SS'));
    
    API.hSI.hScan2D.logFileStem=fileStem;
    API.hSI.hScan2D.logFilePath=saveDir;
    API.hSI.hScan2D.logFileCounter=1;

    API.acquireAndWait;


    mpsf.tools.reapplyScanImageSettings(API,settings);

    API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay; 

    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)

