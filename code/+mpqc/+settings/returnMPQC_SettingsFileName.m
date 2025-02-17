 function MPQC_SettingsFileName = returnMPQC_SettingFileName
    % Return the mpqc settings file name as a string
    %
    % Purpose
    % Multiple files need access to this file name so we define it here once.
    % Returns "MPQC_SystemSettings.yml"
    %
    % Rob Campbell, SWC AMF, initial commit 2022

    MPQC_SettingsFileName = 'MPQC_SystemSettings.yml';

end % returnMPQC_SettingFileName
