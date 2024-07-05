function standard_light_source(channelSave)
    % Record response to the standard light source on all four channels
    %
    % function record.standard_light_source(channelSave)
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
    %
    %
    % Rob Campbell, SWC 2022



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
    settings = mpsf.tools.recordScanImageSettings(API);


    %Apply settings for this acquisition 
    API.setZSlices(1)
    API.hSI.hBeams.powers=0; % set laser power to zero
    API.hSI.hStackManager.framesPerSlice=1; % We will record multiple frames
    API.hSI.hRoiManager.pixelsPerLine=256;

    API.hSI.hScan2D.logAverageFactor = 1;
    API.hSI.hDisplay.volumeDisplayStyle='Current';

    API.hSI.hChannels.loggingEnable=true;


    API.hSI.hChannels.channelSave = channelSave;

    % Get gains to test for each PMT (PMTs can be GaAsp or multi-alkali and this
    % is taken into account here)
    gainsToTest = [];
    for ii=1:length(API.hSI.hPmts.hPMTs)
        gainsToTest = [gainsToTest; getPMTGainsToTest(API.hSI.hPmts.hPMTs{ii})];
    end
    
    API.turnOnPMTs; % Turn on all PMTs
    pause(0.5)


    API.hSI.acqsPerLoop=1;

    for ii=1:length(gainsToTest)
        % Set file name and save dir
        fileStem = sprintf('%s_standard_light_source_%s_%dV__%s', ...
            SETTINGS.microscope.name, ...
            sourceID, ...
            gainsToTest(1,ii), ...
            datestr(now,'yyyy-mm-dd_HH-MM-SS'));

        API.hSI.hScan2D.logFileStem=fileStem;
        API.hSI.hScan2D.logFilePath=lightSourceDir;
        API.hSI.hScan2D.logFileCounter=1;

        API.setPMTgains(gainsToTest(:,ii)); % Set gain
        pause(0.5) % Out of abundance of caution

        API.acquireAndWait;
    end

    API.turnOffPMTs; % Turn off all PMTs


    mpsf.tools.reapplyScanImageSettings(API,settings);

    API.hSI.hChannels.channelSave = API.hSI.hChannels.channelDisplay;

    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)



function gainsToTest = getPMTGainsToTest(hPMT)
    % If the max control voltage is under 2V then it must be a 
    % GaAsP, as those have max control voltage of around 0.9 to 1.5V
    %
    % Also, if the max voltage is 1 or 100 then it's also likely to be a GaAsP


    if hPMT.pmtSupplyRange_V(2) <= 100 || hPMT.aoRange_V(2) <= 2
        isMultiAlkali = false;
    else
        isMultiAlkali = true;
    end

    numGains=12;
    if isMultiAlkali
        gainsToTest = [0,linspace(400,750,numGains)];
    else
        maxV = hPMT.pmtSupplyRange_V(2);
        gainsToTest = [0, linspace(maxV*0.33,maxV*0.8,numGains)];
    end

    gainsToTest = round(gainsToTest);