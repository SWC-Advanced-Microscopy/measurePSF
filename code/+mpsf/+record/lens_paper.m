function lens_paper(varargin)
    % Image lens paper to provide qualitative indications of images quality
    %
    % function mpsf.record.lens_paper('power',value, 'wavelength', value)
    %
    % Purpose
    % Imaging lens paper (e.g. purchased from ThorLabs) is a quick and dirty way of
    % assessing whether image quality is decent. Lens paper is autofluorescent, but
    % weakly so. It has a sparse structure of fibres that does not dim rapidly with
    % depth. It is intrinsically very thin. It can easily be sealed under a coverslip.
    % NOTE: the paper must remain dry for imaging.
    %
    % Running the function
    % User must supply power and wavelengths as integers.
    % This is for logging purposes. If the user fails to do this,
    % they are prompted at CLI. The order of the two arguments
    % does not matter.
    %
    % e.g. In the following example the user is imaging at 920 nm and 10 mW
    % at the sample.
    %
    % >> mpsf.record.lens_paper('wavelength',920,'power',10)
    %
    % e.g. If no inputs are given, user will be prompted for values
    % >> mpsf.record.lens_paper
    %
    % Rob Campbell, SWC 2022
    % Updated: Isabell Whiteley, SWC 2024


    out =  parseInputVariable(varargin{:});
    laser_wavelength=out.wavelength;
    laser_power_in_mW = out.power;


    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    if API.linkSucceeded == false
        return
    end


    saveChanName = API.getSaveChannelName;
    if isempty(saveChanName)
        % message produced by API.getSaveChannelName;
        return
    end

    % Create 'diagnostic' directory in the user's desktop
    saveDir = mpsf.tools.makeTodaysDataDirectory;
    if isempty(saveDir)
        return
    end

    %Record the state of all ScanImage settings we will change so we can change them back
    settings = mpsf.tools.recordScanImageSettings(API);


    %Apply common settings
    API.setZSlices(1)

    API.hSI.hRoiManager.pixelsPerLine=256;

    % We will acquire 5 seconds of data or 40 frames, whichever is larger.
    minFrames = 40;
    fiveSecondsOfFrames = ceil(5 / API.hSI.hRoiManager.scanFramePeriod);
    if fiveSecondsOfFrames < 40
        numFramesToAcquire = minFrames;
    else
        numFramesToAcquire = fiveSecondsOfFrames;
    end

    API.hSI.hStackManager.framesPerSlice=numFramesToAcquire;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hRoiManager.scanZoomFactor = 2; % To keep vignetting down

    API.hSI.hChannels.loggingEnable=true;


    % Set file name and save dir
    SETTINGS=mpsf.settings.readSettings;
    fileStem = sprintf('%s_lens_paper_%dnm_%dmW_%s__%s', ...
        SETTINGS.microscope.name, ...
        laser_wavelength, ...
        laser_power_in_mW, ...
        saveChanName, ...
        datestr(now,'yyyy-mm-dd_HH-MM-SS'));

    API.hSI.hScan2D.logFileStem=fileStem;
    API.hSI.hScan2D.logFilePath=saveDir;
    API.hSI.hScan2D.logFileCounter=1;

    API.acquireAndWait;

    mpsf.tools.reapplyScanImageSettings(API,settings);

    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)

    % Save system settings to this location
    settingsFilePath = mpsf.settings.findSettingsFile;
    copyfile(settingsFilePath, saveDir)
