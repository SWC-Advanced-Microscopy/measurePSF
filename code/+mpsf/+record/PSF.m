function varargout = PSF(varargin)
    % Purpose: Records a z-stack to generate a PSF of beads
    %
    % Records a z-stack of a bead. Images a depth of "micronsToImage"
    % from the current Z position down using steps defined by
    % "stepSizeInMicrons" (0.25 microns by default). Averages using
    % the number of frames entered in the ScanImage IMAGE CONTROLS window.
    % Data will be saved to a TIFF on the desktop in a directory called
    % "PSF". This will be made if needed.
    %
    % Inputs
    % micronsToImage - total depth to image in microns
    % stepSizeInMicrons - number of microns between each z step
    % wavelength - of laser used
    % power - of light
    %
    % Outputs
    % Optionally returns path to the TIFF.
    %
    %
    % Examples
    % 1) Record a 12 micron stack, and prompts user for other inputs.
    % >> record.PSF('micronsToImage',12)
    %
    % 2) Record a 20 micron stack every 0.5 microns and return path to tiff
    % >> F=record.PSF('micronsToImage',20,'stepSizeInMicrons',0.5);
    %
    %
    % Rob Campbell - SWC Nov 2018
    % Updated: Isabell Whiteley, SWC 2024


    out =  parseInputVariable(varargin{:});
    laser_wavelength=out.wavelength;
    laser_power_in_mW = out.power;
    micronsToImage = out.depthMicrons;
    stepSizeInMicrons = out.stepSize;


    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    if API.linkSucceeded == false
        return
    end


    if length(API.hSI.hChannels.channelSave) > 1
        fprintf('Select just one channel to save\n')
        return
    end

    % Create 'PSF' directory in the user's desktop
    saveDir = mpsf.tools.makeTodaysDataDirectory;
    if isempty(saveDir)
        return
    end


    %Record the state of all ScanImage settings we will change so we can change them back
    settings = mpsf.tools.recordScanImageSettings(API);



    % We will set up ScanImage to acquire the z-stack
    framesToAverage = API.hSI.hDisplay.displayRollingAverageFactor;
    numSlices = round(micronsToImage/stepSizeInMicrons);
    fileStem = sprintf('PSF%s%s_%s', ....
            laser_wavelength, ...
            laser_power_in_mW, ...
            datestr(now,'yyyy-mm-dd_HH-MM-SS'));

    try

        if API.versionGreaterThan('2020')
            API.hSI.hStackManager.closeShutterBetweenSlices = false;
            API.hSI.hStackManager.numVolumes = 1;
            API.hSI.hStackManager.stackActuator = 'fastZ';
            API.hSI.hStackManager.centeredStack = 0;
            API.hSI.hStackManager.enable = true;
        else
            API.hSI.hFastZ.enable=false;
            API.hSI.hFastZ.numVolumes=1;
            API.hSI.hStackManager.stackStartCentered=false; %TODO: SI doesn't work correctly when true
            API.hSI.hStackManager.shutterCloseMinZStepSize=stepSizeInMicrons+1;
            API.hSI.hStackManager.slowStackWithFastZ=true;
        end
        %%
        API.hSI.hFastZ.waveformType='step';


        API.hSI.hStackManager.numSlices=numSlices;
        API.hSI.hStackManager.stackZStepSize=stepSizeInMicrons;



        API.hSI.hChannels.loggingEnable=true;

        API.hSI.hScan2D.logFileStem=fileStem;
        API.hSI.hScan2D.logFilePath=saveDir;
        API.hSI.hScan2D.logFileCounter=1;

        API.hSI.hStackManager.framesPerSlice = framesToAverage;
        API.hSI.hScan2D.logAverageFactor = framesToAverage;

        API.hSI.hDisplay.volumeDisplayStyle='Current';
    catch ME
        %If something went wrong we revert the scan settings
        fprintf('Failed to set scan settings\n')
        fprintf(ME.message)
        mpsf.tools.reapplyScanImageSettings(API,settings);
        return
    end


    % Start the acquisition and wait for it to finish
    API.acquireAndWait;

    mpsf.tools.reapplyScanImageSettings(API,settings);

    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)

    % Save system settings to this location
    settingsFilePath = mpsf.settings.findSettingsFile;
    copyfile(settingsFilePath, saveDir)


    if nargout>0
        varargout{1} = pathToTiff;
    end

end % record.PSF
