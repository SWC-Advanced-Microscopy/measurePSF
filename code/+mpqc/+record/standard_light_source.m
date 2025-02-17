function standard_light_source(channelSave,nFrames,gainsToTest)
    % Record response to the standard light source on all four channels
    %
    % function record.standard_light_source(channelSave,nFames,gainsToTest)
    %
    % Purpose
    % Runs through a series of gain values to record signals from the
    % standard source. Places data in their own directory, as there is
    % one file per gain.
    %
    % INSTRUCTIONS
    % 1. You may have multiple standard light sources. If so, enter them
    % into the `QC.sourceIDs` field of the YML file. e.g.
    %  sourceIDs: ['Red_2024Q2','Green_2024Q2','Blue_2024Q2','White_2024Q2']
    % 2. You will then be prompted to enter which is the source when you run the function.
    % 3. CLOSE THE LASER SHUTTER BEFORE STARTING
    %
    % Optional Inputs
    % channelSave - By default this is all four channels (1:4). But the user
    %         can specify anything they like.
    % nFrames - [Optional, 1 by default] If >1 we save this many frames per gain.
    %           There is unlikely to be a reason for this.
    % gainsToTest - vector of gains to test. if empty uses default. TODO --workflow needs fixing here
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2022




    % Connect to ScanImage using the linker class
    API = sibridge.silinker;

    if API.linkSucceeded == false
        return
    end


    % Process input argument
    if nargin<1
        channelSave = 1:API.numberOfAvailableChannels;
    else
        channelSave = unique(channelSave);
        if length(channelSave)>API.numberOfAvailableChannels || ...
            any(channelSave<1) || ...
            any(channelSave>API.numberOfAvailableChannels)
            channelSave = 1:API.numberOfAvailableChannels;
        end
    end


    if nargin<2 || isempty(nFrames)
        nFrames = 1;
    end


    if nargin<3
        gainsToTest = [];
    end

    % Create 'diagnostic' directory in the user's desktop
    saveDir = mpqc.tools.makeTodaysDataDirectory;
    if isempty(saveDir)
        return
    end

    % Determine the name of the files we will be saving
    SETTINGS=mpqc.settings.readSettings;

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

    %Record the state of all ScanImage settings we will change so we can change them back
    initialSettings = mpqc.tools.recordScanImageSettings(API);

    %Apply settings for this acquisition
    API.setZSlices(1) % Just one z slice
    API.hSI.hBeams.powers=0; % set laser power to zero
    API.hSI.hStackManager.framesPerSlice=nFrames; % Optionally we will record multiple frames
    API.hSI.hRoiManager.pixelsPerLine=256;

    API.hSI.hScan2D.logAverageFactor = 1; % Do not average frames
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hChannels.loggingEnable=true;


    API.hSI.hChannels.channelSave = channelSave;



    API.turnOnAllPMTs; % Turn on all PMTs
    pause(0.5)


    API.hSI.acqsPerLoop=1;
    if isempty(gainsToTest)
        gainsToTest = getPMTGainsToTest;
    end
    for ii=1:length(gainsToTest)
        % Set file name and save dir
        fileStem = sprintf('%s_standard_light_source_%s_%dV__%s', ...
            SETTINGS.microscope.name, ...
            sourceID, ...
            gainsToTest(1,ii), ...
            datestr(now,'yyyy-mm-dd_HH-MM-SS'));

        API.hSI.hScan2D.logFileStem=fileStem;
        API.hSI.hScan2D.logFilePath=saveDir;
        API.hSI.hScan2D.logFileCounter=1;

        API.setPMTgains(gainsToTest(:,ii)); % Set gain
        pause(1) % Let's wait for it to stabilise

        API.acquireAndWait;
    end


    % Report saved file location and copy mpqc settings there
    postAcqTasks(saveDir,fileStem)


    API.turnOffAllPMTs; % Turn off all PMTs
    % Return ScanImage to the state it was in before we started.
    mpqc.tools.reapplyScanImageSettings(API,initialSettings);
    API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;

end
