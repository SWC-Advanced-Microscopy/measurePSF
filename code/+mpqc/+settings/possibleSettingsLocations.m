function settingsDirs = possibleSettingsLocations
    % Return all possible user settings locations of the MPSF package
    %
    % function settingsDirs = mpqc.settings.possibleSettingsLocations()
    %
    % Prurpose
    % Return all possible user settings directory locations for the MPSF package.
    % This is used by mpqc.settings.findSettingsFile to determine where the settings file
    % is located.
    %
    % Outputs
    % settingsDirs - A structure containing the possible settings file locations
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2022


    n = 0;

    % In C:\ (on Windows)
    if ispc
        n = n+1;
        settingsDirs(n).settingsLocation = fullfile('C:\', 'MPSF_Settings');
        settingsDirs(n).backupSettingsLocation = fullfile(settingsDirs(n).settingsLocation,'BackupSettings');
            settingsDirs(n).locationType = 'C';
    end


    % User's home directory
    userFolder = mpqc.settings.userFolder;
    if ~isempty(userFolder)
        n = n+1;
        settingsDirs(n).settingsLocation = fullfile(userFolder,'MPSF_Settings');
        settingsDirs(n).backupSettingsLocation = fullfile(settingsDirs(n).settingsLocation,'BackupSettings');
        settingsDirs(n).locationType = 'homefolder';
    end


    % Check what exists
    for ii=1:length(settingsDirs)
        settingsDirs(ii).settingsLocation_exists = ...
            exist(settingsDirs(ii).settingsLocation,'dir')>0;
        settingsDirs(ii).backupSettingsLocation_exists = ...
            exist(settingsDirs(ii).backupSettingsLocation,'dir')>0;
    end


end % possibleSettingsLocations
