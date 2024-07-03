function rootDir = makeDataRootDirectory
    % Make a data directory in the desktop to house all measure PSF data
    %
    % mpsf.tools.makeDataRootDirectory
    %
    % Purpose
    % Makes the data root directory in the user's Desktop. If the directory
    % already exists, only the path is returned. Gets all information needed 
    % from user settings and mpsf.constants The directory it makes is in the
    % form "SYSTEMNAME_diagnostics"
    %
    % Inputs 
    % none
    %
    % Outputs
    % rootDir - the full path to the folder
    %
    % Example
    % >> mpsf.tools.makeDataRootDirectory
    %
    % ans =
    % 
    % 'C:\Users\kiosk\Desktop\NeuroVision_diagnostics'
    %
    %
    % Rob Campbell - SWC 2024


    rootDir = mpsf.tools.makeDesktopDirectory(mpsf.constants.rootDir);

end
