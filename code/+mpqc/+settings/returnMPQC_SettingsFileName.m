 function MPSF_SettingsFileName = returnMPSF_SettingFileName
    % Return the mpqc settings file name as a string
    %
    % Purpose
    % Multiple files need access to this file name so we define it here once.
    % Returns "MPSF_SystemSettings.yml"
    %
    % Rob Campbell, SWC AMF, initial commit 2022

    MPSF_SettingsFileName = 'MPSF_SystemSettings.yml';

end % returnMPSF_SettingFileName
