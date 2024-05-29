function dirPath = makeTodaysDataDirectory
    % Make a data directory for all data generated today
    %
    % mpsf.tools.makeTodaysDataDirectory
    %
    % Details
    % Gets all information needed from user settings and mpsf.constants
    %
    % Inputs 
    % none
    %
    % Outputs
    % dirPath - the full path to the folder. Empty if it could not be made. 
    %
    %
    % Rob Campbell - SWC 2024


    rootDirPath = mpsf.tools.makeDataRootDirectory;

    if isempty(rootDirPath) || ~exist(rootDirPath,'dir')
        dirPath = [];
        return
    end

    s = mpsf.settings.readSettings;
    tDir = sprintf('%s__%s', s.microscope.name, datestr(now,'yyyy_mm_dd'));

    dirPath = fullfile(rootDirPath,tDir);

    if ~exist(dirPath,'dir')
        mkdir(dirPath);
    end

    if ~exist(dirPath,'dir')
        dirPath = [];
    end


end
