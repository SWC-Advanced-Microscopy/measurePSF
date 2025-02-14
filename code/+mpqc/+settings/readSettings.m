function reformattedSettings = readSettings(fname)
    % Read MPSF settings YAML file and return as a structure
    %
    % function settings = mpqc.settings.readSettings()
    %
    % Purpose
    % This function parses the MPSF settings file and creates it if does not already exist.
    %
    % If no settings have been created then a default settings file is created. The user is
    % prompted to edit it and nothing is returned. If a settings file is present and looks
    % identical to the default one, the user is prompted to edit it and nothing is returned.
    % Otherwise the settings file is read and returned as a structure.
    %
    % Inputs
    % fname - [optional] If not provided, the default settings file is found and loaded. If
    %       fname is provided, this is loaded instead. A non-standard settings file is only
    %       used for running certain tests. The settings file is never modified if this
    %       this arg is defined.
    %
    % Outputs
    % settings - the mpqc settings as a structure
    %
    %
    % Rob Campbell, Biozentrum Basel, initial commit 2017


    outputSettings = [];
    allValid = true; % By default all settings are valid
    if nargin<1
        fname = [];
    end


    if isempty(fname)
        [settingsFile,backupSettingsDir] = mpqc.settings.findSettingsFile;
    else
        % cope with wildcards
        if contains(fname,'*')
            d = dir(fname);
            if length(d)==1
                fname = d.name;
            end
        end
        settingsFile = fname;
        backupSettingsDir = []; % Do not write to backup settings at all
    end


    if ~exist(settingsFile,'file')
        fprintf('Can not find settings file %s\n', settingsFile)
        return
    end


    settingsFromYML = mpqc.yaml.ReadYaml(settingsFile);

    %Check if the loaded settings are the same as the default settings
    DEFAULT_SETTINGS = mpqc.settings.default_settings;

    % TODO -- does this ever run? Can we delete it?
    if isequal(settingsFromYML,DEFAULT_SETTINGS)
        fprintf(['\n\n *** The settings file at %s has never been edited\n ', ...
            '*** Press RETURN then edit the file for your system.\n'], settingsFile)

        pause

        edit(settingsFile)
        fprintf('\n\n *** Once you have finished editing the file, save it and press RETURN\n')

        pause
        outputSettings = mpqc.settings.readSettings;
        [outputSettings,allValid] = mpqc.settings.checkSettingsAreValid(outputSettings);
        return
    end



    % The following steps to ensure that the values in the user settings file are correct.


    %%
    % One
    % Report missing values to user settings file.
    % These will be added implicitly in the third step.

    f0 = fields(DEFAULT_SETTINGS);
    addedDefaultValue = false;
    outputSettings = DEFAULT_SETTINGS;

    for ii = 1:length(f0);
        f1 = fields(DEFAULT_SETTINGS.(f0{ii}));

        % There is a whole section missing
        if ~isfield(settingsFromYML,f0{ii});
            fprintf('\n\n Added missing section "%s" from default_Settings.m\n', f0{ii})
            addedDefaultValue = true;
            continue
        end

        for jj = 1:length(f1)
            if ~isfield(settingsFromYML.(f0{ii}), f1{jj})
                addedDefaultValue = true;
                fprintf('\n\n Adding missing default setting "%s.%s" from default_Settings.m\n', ...
                    f0{ii}, f1{jj})
            end
        end
    end


    %%
    % Two
    % Go through the user's settings file and replace all fields in the default file with those.
    % This ensures that: 1) Any fields not in the user's file will appear and 2) any values only
    % in the user file will just vanish
    f0 = fields(DEFAULT_SETTINGS);
    for ii = 1:length(f0);
        f1 = fields(DEFAULT_SETTINGS.(f0{ii}));



        if ~isfield(settingsFromYML, f0{ii})
            % The section is missing from the user settings file so we will use the defaults
            allValid = false;
            continue
        end

        if ~isequal( fields(DEFAULT_SETTINGS.(f0{ii})),  fields(settingsFromYML.(f0{ii})) )
            % If the two have different fields then we need to replace the user settings
            % file on disk. This catches the case where the user has an old setting in
            % their user settings file and we want to remove it by re-saving the file.
            allValid = false;
        end
        for jj = 1:length(f1)
            if isfield(settingsFromYML.(f0{ii}), f1{jj})
                outputSettings.(f0{ii}).(f1{jj}) = settingsFromYML.(f0{ii}).(f1{jj});
            end
        end
    end


    % Do a final tidy to handle corner cases (caution: hard-coded stuff here!)
    if isempty(outputSettings.QC.sourceIDs)
        % Replace with an empty cell array
        outputSettings.QC.sourceIDs={};
    end


    %%
    % Three
    % Make sure all settings that are returned are valid
    % If they are not, we replace them with the original default value
    [outputSettings,allValidCheck] = mpqc.settings.checkSettingsAreValid(outputSettings); % see private directory

    % Because settings will return as valid even if an old setting exists.
    allValid = allValid * allValidCheck;

    if ~allValid
        fprintf('\n ********************************************************************\n')
        fprintf(' * YOU HAVE INVALID OR OLD SETTINGS IN %s. \n', settingsFile)
        fprintf(' * They have been replaced with valid defaults. \n')
        fprintf(' **********************************************************************\n')
    end



    % Reformat the settings so we have a list of structures for the lasers and PMTs and we
    % remove empty entries.
    reformattedSettings = outputSettings;
    reformattedSettings.PMTs = reformattedSettings.PMT_1;
    reformattedSettings.imagingLasers = reformattedSettings.imagingLaser_1;
    nPMT=1; % counter for adding PMTs
    nLaser=1; % counter for adding lasers
    for ii=1:4
        tPMT = sprintf('PMT_%d',ii);
        tLaser = sprintf('imagingLaser_%d',ii);

        if isfield(reformattedSettings,tPMT)
            if ~isempty(reformattedSettings.(tPMT).model)
                reformattedSettings.PMTs(nPMT) = reformattedSettings.(tPMT);
                nPMT = nPMT+1;
                reformattedSettings = rmfield(reformattedSettings,tPMT);
            else
                reformattedSettings = rmfield(reformattedSettings,tPMT);
            end
        end


        if isfield(reformattedSettings,tLaser)
            if ~isempty(reformattedSettings.(tLaser).model)
                reformattedSettings.imagingLasers(nLaser) = reformattedSettings.(tLaser);
                nLaser = nLaser+1;
                reformattedSettings = rmfield(reformattedSettings,tLaser);
            else
                reformattedSettings = rmfield(reformattedSettings,tLaser);
            end
        end

    end



    % Make sure the microscope name does not contain weird characters
    outputSettings.microscope.name = regexprep(outputSettings.microscope.name, ' ','-');
    outputSettings.microscope.name = regexprep(outputSettings.microscope.name, '[^0-9a-z_A-Z-]','');

    % If there are missing or invalid values we will replace these in the settings file as well as making
    % a backup copy of the original file.
    if isempty(backupSettingsDir)
        return
    end

    if ~allValid || addedDefaultValue
        % Copy file
        if ~exist(backupSettingsDir,'dir')
            mkdir(backupSettingsDir)
        end
       backupFname = fullfile(backupSettingsDir, ...
            [datestr(now, 'yyyy_mm_dd__HH_MM_SS_'),mpqc.settings.returnMPSF_SettingsFileName]);
       fprintf('Making backup of settings file at %s\n', backupFname)
       copyfile(settingsFile,backupFname)

       % Write the new file to the settings location
       fprintf('Replacing settings file with updated version\n')
       mpqc.yaml.WriteYaml(settingsFile,outputSettings);
    end

    % Ensure we don't have too many backup files
    backupFiles = dir(fullfile(backupSettingsDir,'*.yml'));
    maxBackUps = 10;  % keep max 10 backup files
    if length(backupFiles) > maxBackUps
        [~,ind]=sort([backupFiles.datenum],'descend');
        backupFiles = backupFiles(ind); % make certain they are in date order
        backupFiles = backupFiles(maxBackUps+1:end);
        % Delete only these
        for ii = length(backupFiles):-1:1
            delete(fullfile(backupFiles(ii).folder,backupFiles(ii).name))
        end
    end

end % readSettings
