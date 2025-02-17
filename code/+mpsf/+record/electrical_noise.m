function electrical_noise(channelSave)
    % Record electrical noise on all four channels
    %
    % function record.electrical_noise()
    %
    % CAUTION: will turn on PMTs! ENSURE THERE IS NO LIGHT SOURCE OR SAMPLE!
    %
    % e.g.
    % >> mpsf.record.electrical_noise
    %
    % Optional Inputs
    % channelSave - By default this is all four channels (1:4). But the user
    %         can specify anything they like.
    %
    % Rob Campbell, SWC 2022


    fprintf('Remove sample and ensure enclosure is dark then press return\n')
    pause

    % Process input argument
    if nargin<1
        channelSave = 1:4;
    else
        channelSave = unique(channelSave);
        if length(channelSave)>4 || any(channelSave<1) || any(channelSave>4)
            channelSave = 1:4;
        end
    end

    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    API.hSI.hChannels.channelSave = channelSave;

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


    mpsf.tools.reapplyScanImageSettings(API,settings);

    API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;

    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)

