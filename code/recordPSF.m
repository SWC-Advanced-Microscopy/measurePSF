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



    %Get ScanImage API handle
    scanimageObjectName='hSI';
    W = evalin('base','whos');
    SIexists = ismember(scanimageObjectName,{W.name});
    if ~SIexists
        fprintf('ScanImage not started or no ScanImage object in base workspace\n')
        return
    end

    API = evalin('base',scanimageObjectName); % get hSI from the base workspace


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

    fastZEnable = API.hFastZ.enable;         
    fastZNumVolumes = API.hFastZ.numVolumes; 
    fastZwaveform = API.hFastZ.waveformType;

    stackManCentr = API.hStackManager.stackStartCentered;
    stackManNumSlices = API.hStackManager.numSlices; 
    stackManStepSize = API.hStackManager.stackZStepSize;
    stackManShutterClose = API.hStackManager.shutterCloseMinZStepSize;
    stackManSlowFastZ = API.hStackManager.slowStackWithFastZ;

    loggingEnabled = API.hChannels.loggingEnable; 
    logAveFact = API.hScan2D.logAverageFactor;
    framesPerSlice = API.hStackManager.framesPerSlice;

    logFileStem = API.hScan2D.logFileStem;
    logFilePath = API.hScan2D.logFilePath;
    logFileCounter = API.hScan2D.logFileCounter;

    % We will set up ScanImage to acquire the z-stack
    framesToAverage = API.hDisplay.displayRollingAverageFactor;
    numSlices = round(micronsToImage/stepSizeInMicrons);
    fileStem = sprintf('PSF_%s', datestr(now,'YYYY-MM-DD_HH-mm-ss'));

    try
        API.hFastZ.enable=false;
        API.hFastZ.numVolumes=1;
        API.hFastZ.waveformType='step';

        API.hStackManager.stackStartCentered=false; %TODO: SI doesn't work correctly when true
        API.hStackManager.numSlices=numSlices;
        API.hStackManager.stackZStepSize=stepSizeInMicrons;
        API.hStackManager.shutterCloseMinZStepSize=stepSizeInMicrons+1;
        API.hStackManager.slowStackWithFastZ=true;

        API.hChannels.loggingEnable=true;

        API.hScan2D.logFileStem=fileStem;
        API.hScan2D.logFilePath=PSFdir;
        API.hScan2D.logFileCounter=1;

        API.hStackManager.framesPerSlice = framesToAverage;
        API.hScan2D.logAverageFactor = framesToAverage;

        API.hDisplay.volumeDisplayStyle='Current'; % We won't bother about retaining this
    catch ME
        %If something went wrong we revert the scan settings
        fprintf('Failed to set scan settings\n')
        fprintf(ME.message)
        revertScanSettings
        return
    end


    % Start the acquisition and wait for it to finish
    API.startGrab
    while 1
        if strcmp(API.acqState,'idle') %Break when finished
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

        API.hFastZ.enable = fastZEnable;         %We will set this to false

        API.hFastZ.numVolumes = fastZNumVolumes; % Will set to 1
        API.hFastZ.waveformType = fastZwaveform; %set to 'step'

        API.hStackManager.stackStartCentered = stackManCentr;
        API.hStackManager.numSlices = stackManNumSlices; 
        API.hStackManager.stackZStepSize = stackManStepSize;
        API.hStackManager.shutterCloseMinZStepSize = stackManShutterClose; %twice the step size we use
        API.hStackManager.slowStackWithFastZ = stackManSlowFastZ; %This will be enabled

        API.hChannels.loggingEnable = loggingEnabled; 
        API.hScan2D.logAverageFactor = logAveFact; %Set to framestoAverage
        API.hStackManager.framesPerSlice = framesPerSlice; %This will be framestoAverage

        API.hScan2D.logFileStem = logFileStem;
        API.hScan2D.logFilePath = logFilePath;
        API.hScan2D.logFileCounter = logFileCounter;
    end %cleanUpFunction

end % recordPSF