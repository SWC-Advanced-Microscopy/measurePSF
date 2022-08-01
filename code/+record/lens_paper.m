function lens_paper(laser_power_in_mW,laser_wavelength)
    % Image lens paper to analyse SNR.
    %
    % function lens_paper(laser_power_in_mW,laser_wavelength)
    %
    % User must supply power and wavelengths as integers.
    % This is for logging purposes.
    %
    % e.g.
    % >> record.lens_paper(10,920)
    %
    % Rob Campbell, SWC 2022

    if nargin<2 || ( ~isnumeric(laser_power_in_mW) || ~isnumeric(laser_wavelength) )
        fprintf('Supply power and wavelength as input args. See function help\n')
        return
    end

    laser_power_in_mW = round(laser_power_in_mW);
    laser_wavelength = round(laser_wavelength);

    % Connect to ScanImage using the linker class
    API = sibridge.silinker;
    
    if length(API.hSI.hChannels.channelSave) > 1
        fprintf('Select just one channel to save\n')
        return
    end

    % Create 'diagnostic' directory in the user's desktop
    saveDir = mpsf_tools.makeDesktopDirectory('diagnostic');
    if isempty(saveDir)
        return
    end

    %Record the state of all ScanImage settings we will change so we can change them back
    settings = mpsf_tools.recordScanImageSettings(API);


    %Apply common setting
    if API.versionGreaterThan('2020') 
        API.hSI.hStackManager.numSlices=1;
        API.hSI.hStackManager.numVolumes = 1;
    else
        API.hSI.hStackManager.numSlices=1;
        API.hSI.hFastZ.numVolumes=1;
    end

    API.hSI.hStackManager.framesPerSlice=40; % We will record multiple frames
    API.hSI.hRoiManager.pixelsPerLine=256;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hRoiManager.scanZoomFactor = 2; % To keep vignetting down

    API.hSI.hChannels.loggingEnable=true;


    % Set file name and save dir
    fileStem = sprintf('lens_paper_%dnm_%dmW__%s', ...
            laser_wavelength, ...
            laser_power_in_mW, ...
            datestr(now,'yyyy-mm-dd_HH-MM-SS'));
    
    API.hSI.hScan2D.logFileStem=fileStem;
    API.hSI.hScan2D.logFilePath=saveDir;
    API.hSI.hScan2D.logFileCounter=1;

    API.acquireAndWait;



    mpsf_tools.reapplyScanImageSettings(API,settings);

    % Report where the file was saved
    mpsf_tools.reportFileSaveLocation(saveDir,fileStem)

