function rootDir = makeDataRootDirectory
    % Make a data directory in the desktop to house all measure PSF data
    %
    % mpsf.tools.makeDataRootDirectory
    %
    % Details
    % Gets all information needed from user settings and mpsf.constants
    %
    % Inputs 
    % none
    %
    % Outputs
    % rootDir - the full path to the folder
    %
    %
    % Rob Campbell - SWC 2024


    rootDir = mpsf.tools.makeDesktopDirectory(mpsf.constants.rootDir);

end
