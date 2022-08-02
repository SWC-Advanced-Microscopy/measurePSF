function settings = reapplyScanImageSettings(API,settings)
% Record settings from ScanImage 
%
% function settings = reapplyScanImageSettings(API,settings)
%
%
% Inputs
% API - silinker object
% settings - output for recordScanImageSettings
%
% Output
% settings - structure of settings
%
% See also
% recordScanImageSettings



    if API.versionGreaterThan('2020') 
        API.hSI.hStackManager.closeShutterBetweenSlices = settings.stackManShutterClose;
        API.hSI.hStackManager.numVolumes = settings.numVolumes;
        API.hSI.hStackManager.stackActuator = settings.stackActuator;
        API.hSI.hStackManager.enable = settings.stackManEnable;
        API.hSI.hStackManager.centeredStack = settings.stackManCentr;
    else
        API.hSI.hFastZ.enable = settings.fastZEnable;
        API.hSI.hFastZ.numVolumes = settings.fastZNumVolumes;
        API.hSI.hStackManager.stackStartCentered = settings.stackManCentr;
        API.hSI.hStackManager.shutterCloseMinZStepSize =  settings.stackManShutterClose;
        API.hSI.hStackManager.slowStackWithFastZ = settings.stackManSlowFastZ;
    end

    API.hSI.hRoiManager.scanZoomFactor = settings.zoomFactor;

    API.hSI.hFastZ.waveformType = settings.fastZwaveform;
    API.hSI.hStackManager.numSlices = settings.stackManNumSlices; 
    API.hSI.hStackManager.stackZStepSize = settings.stackManStepSize;

    API.hSI.hChannels.loggingEnable = settings.loggingEnabled; 
    API.hSI.hScan2D.logAverageFactor = settings.logAveFact;
    API.hSI.hStackManager.framesPerSlice = settings.framesPerSlice;

    API.hSI.hScan2D.logFileStem = settings.logFileStem;
    API.hSI.hScan2D.logFilePath = settings.logFilePath;
    API.hSI.hScan2D.logFileCounter = settings.logFileCounter;