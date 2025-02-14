function standard_light_source(channelSave,nFrames)
    % Record response to the standard light source on all four channels
    %
    % function record.standard_light_source(channelSave,nFames)
    %
    % Purpose
    % Runs through a series of gain values to record signals from the
    % standard source. Places data in their own directory, as there is
    % one file per gain.
    %
    % INSTRUCTIONS
    % You may have multiple standard light sources. If so, enter them
    % into the `QC.sourceIDs` field of the YML file. e.g.
    %  sourceIDs: ['Red_2024Q2','Green_2024Q2','Blue_2024Q2','White_2024Q2']
    % You will then be prompted to enter which is the source when you run the function.
    %
    %
    % Optional Inputs
    % channelSave - By default this is all four channels (1:4). But the user
    %         can specify anything they like.
    % nFrames - [Optional, 1 by default] If >1 we save this many frames per gain.
    %           There is unlikely to be a reason for this.
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2022



    % Process input argument
    % TODO: https://github.com/SWC-Advanced-Microscopy/measurePSF/issues/78
    if nargin<1
        channelSave = 1:4;
    else
        channelSave = unique(channelSave);
        if length(channelSave)>4 || any(channelSave<1) || any(channelSave>4)
            channelSave = 1:4;
        end
    end

    if nargin<2
        nFrames = 1;
    end


    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    if API.linkSucceeded == false
        return
    end


    % Create 'diagnostic' directory in the user's desktop
    saveDir = mpsf.tools.makeTodaysDataDirectory;
    if isempty(saveDir)
        return
    end

    % Determine the name of the files we will be saving
    SETTINGS=mpsf.settings.readSettings;

    if ~isempty(SETTINGS.QC.sourceIDs)
        if length(SETTINGS.QC.sourceIDs)==1
            sourceID = SETTINGS.QC.sourceIDs{1};
        elseif length(SETTINGS.QC.sourceIDs)>1
            fprintf('Select source ID:\n')
            for ii=1:length(SETTINGS.QC.sourceIDs)
                fprintf('%d. %s\n', ii, SETTINGS.QC.sourceIDs{ii})
            end
            selectedIndex = [];
            while isempty(selectedIndex)
                response = input('Enter source number and press return: ');
                if isnumeric(response) && isscalar(response) && ...
                 response>0 && response<=length(SETTINGS.QC.sourceIDs)
                 selectedIndex = response;
             end
            end
            sourceID = SETTINGS.QC.sourceIDs{selectedIndex};
        end
    else
        sourceID = 'UNSPECIFIED_SOURCE';
        fprintf('NOTE: it is recommended you enter your standard light source names into the YML file.\n')
        fprintf('See function help text\n')
    end

    % Now make the sub-directory
    subDirName = sprintf('%s_standard_light_source_%s__%s', ...
            SETTINGS.microscope.name, ...
            sourceID, ...
            datestr(now,'yyyy-mm-dd_HH-MM'));

    lightSourceDir = fullfile(saveDir,subDirName);
    mkdir(lightSourceDir)

    %Record the state of all ScanImage settings we will change so we can change them back
    initialSettings = mpsf.tools.recordScanImageSettings(API);

    %Define a cleanup object
    tidyUp = onCleanup(@cleanupAfterAcquisition);

    %Apply settings for this acquisition
    API.setZSlices(1) % Just one z slice
    API.hSI.hBeams.powers=0; % set laser power to zero
    API.hSI.hStackManager.framesPerSlice=nFrames; % Optionally we will record multiple frames
    API.hSI.hRoiManager.pixelsPerLine=128;

    API.hSI.hScan2D.logAverageFactor = 1; % Do not average frames
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hChannels.loggingEnable=true;


    API.hSI.hChannels.channelSave = channelSave;



    API.turnOnPMTs; % Turn on all PMTs
    pause(0.5)


    API.hSI.acqsPerLoop=1;
    gainsToTest = getPMTGainsToTest;
    for ii=1:length(gainsToTest)
        % Set file name and save dir
        fileStem = sprintf('%s_standard_light_source_%s_%dV__%s', ...
            SETTINGS.microscope.name, ...
            sourceID, ...
            gainsToTest(1,ii), ... %TODO! This is only first PMT gain!
            datestr(now,'yyyy-mm-dd_HH-MM-SS'));

        API.hSI.hScan2D.logFileStem=fileStem;
        API.hSI.hScan2D.logFilePath=lightSourceDir;
        API.hSI.hScan2D.logFileCounter=1;

        API.setPMTgains(gainsToTest(:,ii)); % Set gain
        pause(0.5) % Out of abundance of caution

        API.acquireAndWait;
    end


    % Report saved file location and copy mpsf settings there
    postAcqTasks(saveDir,fileStem)


    % Nested cleanup function that will return ScanImage to its original settings. The
    % cleanup function was defined near the top of the file.
    function cleanupAfterAcquisition
       API.turnOffPMTs; % Turn off all PMTs
       % Return ScanImage to the state it was in before we started.
       mpsf.tools.reapplyScanImageSettings(API,initialSettings);
       API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;
    end

end
