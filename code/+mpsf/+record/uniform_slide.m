function uniform_slide(varargin)
    % Image uniform slide
    %
    % function mpsf.record.uniform_slide(laser_power_in_mW,laser_wavelength)
    %
    % User must supply power and wavelengths as integers.
    % This is for logging purposes. If the user fails to do this,
    % they are prompted at CLI. The order of the two arguments
    % does not matter.
    %
    % e.g.
    % >> mpsf.record.uniform_slide
    % >> mpsf.record.uniform_slide('wavelength',920,'power',10)
    %
    %
    % Rob Campbell, SWC 2022
    % Updated: Isabell Whiteley, SWC 2024
    
    out =  parseInputVariable(varargin{:});
    laser_wavelength=out.wavelength;
    laser_power_in_mW = out.power;

    % Connect to ScanImage using the linker class
    API = sibridge.silinker;
    if ~strcmp(API.scannerType,'resonant')
        fprintf('%s only safe with resonant scanner. Quitting. \n',mfilename)
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


    %Apply common setting
    API.setZSlices(1)

    API.hSI.hStackManager.framesPerSlice=20; % We will record multiple frames
    API.hSI.hRoiManager.pixelsPerLine=256;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';


    API.hSI.hRoiManager.scanZoomFactor = 1; % Set zoom

    API.hSI.hChannels.loggingEnable=true;

    % Set file name and save dir
    SETTINGS=mpsf.settings.readSettings;
    fileStem = sprintf('%s_uniform_slide_zoom__%s_%dnm_%dmW_%s__%s', ...
        SETTINGS.microscope.name, ...
        strrep(num2str(API.hSI.hRoiManager.scanZoomFactor),'.','-'), ...
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

