function varargout=recordPSF(micronsToImage, stepSizeInMicrons)

% function recordPSF(micronsToImage, stepSizeInMicrons)
%
% Purpose
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
%
% Outputs
% Optionally returns path to the TIFF.
%
%
% Examples
% 1) Record a 12 micron stack every 0.25 microns
% >> recordPSF(12) 
%
% 2) Record a 20 micron stack every 0.5 microns and return path to tiff 
% >> F=recordPSF(20,0.5);
%
%
% Rob Campbell - SWC Nov 2018


    micronsToImage = abs(micronsToImage);
    if nargin<2 || isempty(stepSizeInMicrons)
        stepSizeInMicrons=0.25;
    end

    if nargin<3 || isempty(framesToAverage)
        framesToAverage=25;
    end



    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    % Create 'PSF' directory in the user's desktop
    [~, userdir] = system('echo %USERPROFILE%');
    tmp=regexp(userdir,'([\d\w:\\]*)','tokens');
    userdir=tmp{1}{1};
    if ~exist(userdir,'dir')
        fprintf('Can not find user directory: %s\n', userdir)
        return
    end
    PSFdir = fullfile(userdir,'Desktop\PSF');

    if ~exist(PSFdir,'dir')
        mkdir(PSFdir)
    end

    if ~exist(PSFdir,'dir')
        fprintf('Can not access or create directory %s\n', PSFdir)
    end




    %Record the state of all ScanImage settings we will change so we can change them back



    if API.versionGreaterThan('2020') 
        stackManShutterClose = API.hSI.hStackManager.closeShutterBetweenSlices;
        numVolumes = API.hSI.hStackManager.numVolumes;
        stackActuator = API.hSI.hStackManager.stackActuator;
        stackManCentr = API.hSI.hStackManager.centeredStack;
        stackManEnable = API.hSI.hStackManager.enable;
    else
        fastZEnable = API.hSI.hFastZ.enable;
        fastZNumVolumes = API.hSI.hFastZ.numVolumes; 
        stackManCentr = API.hSI.hStackManager.stackStartCentered;
        stackManShutterClose = API.hSI.hStackManager.shutterCloseMinZStepSize;
        stackManSlowFastZ = API.hSI.hStackManager.slowStackWithFastZ;  %This will be enabled
    end 

    fastZwaveform = API.hSI.hFastZ.waveformType;

    
    stackManNumSlices = API.hSI.hStackManager.numSlices; 
    stackManStepSize = API.hSI.hStackManager.stackZStepSize;


    loggingEnabled = API.hSI.hChannels.loggingEnable; 
    logAveFact = API.hSI.hScan2D.logAverageFactor;
    framesPerSlice = API.hSI.hStackManager.framesPerSlice;

    logFileStem = API.hSI.hScan2D.logFileStem;
    logFilePath = API.hSI.hScan2D.logFilePath;
    logFileCounter = API.hSI.hScan2D.logFileCounter;

    % We will set up ScanImage to acquire the z-stack
    framesToAverage = API.hSI.hDisplay.displayRollingAverageFactor;
    numSlices = round(micronsToImage/stepSizeInMicrons);
    fileStem = sprintf('PSF_%s', datestr(now,'yyyy-mm-dd_HH-MM-SS'));

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
        API.hSI.hScan2D.logFilePath=PSFdir;
        API.hSI.hScan2D.logFileCounter=1;

        API.hSI.hStackManager.framesPerSlice = framesToAverage;
        API.hSI.hScan2D.logAverageFactor = framesToAverage;

        API.hSI.hDisplay.volumeDisplayStyle='Current'; % We won't bother about retaining this
    catch ME
        %If something went wrong we revert the scan settings
        fprintf('Failed to set scan settings\n')
        fprintf(ME.message)
        revertScanSettings
        return
    end


    % Start the acquisition and wait for it to finish
    API.hSI.startGrab
    while 1
        if strcmp(API.hSI.acqState,'idle') %Break when finished
            break
        end
        pause(0.25)
    end

    revertScanSettings

    % Report where the file was saved
    D = dir([fullfile(PSFdir,fileStem),'*']);
    pathToTiff = fullfile(PSFdir,D.name);
    fprintf('Saved data to %s\n', pathToTiff)



    if nargout>0
        varargout{1} = pathToTiff;
    end



    function revertScanSettings
        % Return settings to original values
        fprintf('Finished\n')



        if API.versionGreaterThan('2020') 
            API.hSI.hStackManager.closeShutterBetweenSlices = stackManShutterClose;
            API.hSI.hStackManager.numVolumes = numVolumes;
            API.hSI.hStackManager.stackActuator = stackActuator;
            API.hSI.hStackManager.enable = stackManEnable;
            API.hSI.hStackManager.centeredStack = stackManCentr;
        else
            API.hSI.hFastZ.enable = fastZEnable;         %We will set this to false
            API.hSI.hFastZ.numVolumes = fastZNumVolumes;
            API.hSI.hStackManager.stackStartCentered = stackManCentr;
            API.hSI.hStackManager.shutterCloseMinZStepSize = stackManShutterClose; %twice the step size we use
            API.hSI.hStackManager.slowStackWithFastZ = stackManSlowFastZ;
        end

        API.hSI.hFastZ.waveformType = fastZwaveform; %set to 'step'

        API.hSI.hStackManager.numSlices = stackManNumSlices; 
        API.hSI.hStackManager.stackZStepSize = stackManStepSize;

        API.hSI.hChannels.loggingEnable = loggingEnabled; 
        API.hSI.hScan2D.logAverageFactor = logAveFact; %Set to framestoAverage
        API.hSI.hStackManager.framesPerSlice = framesPerSlice; %This will be framestoAverage

        API.hSI.hScan2D.logFileStem = logFileStem;
        API.hSI.hScan2D.logFilePath = logFilePath;
        API.hSI.hScan2D.logFileCounter = logFileCounter;
    end %cleanUpFunction

end % recordPSF