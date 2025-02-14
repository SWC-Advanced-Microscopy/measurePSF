function rootDir = makeDataRootDirectory
    % Make a data directory in the desktop to house all measure PSF data
    %
    % mpqc.tools.makeDataRootDirectory
    %
    % Purpose
    % Makes the data root directory in the user's Desktop. If the directory
    % already exists, only the path is returned. Gets all information needed
    % from user settings and mpqc.constants The directory it makes is in the
    % form "SYSTEMNAME_diagnostics"
    %
    % Inputs
    % none
    %
    % Outputs
    % rootDir - the full path to the folder
    %
    % Example
    % >> mpqc.tools.makeDataRootDirectory
    %
    % ans =
    %
    % 'C:\Users\kiosk\Desktop\NeuroVision_diagnostics'
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2024


    rootDir = mpqc.tools.makeDesktopDirectory(mpqc.constants.rootDir);

end
