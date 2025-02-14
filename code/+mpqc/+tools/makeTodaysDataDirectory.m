function dirPath = makeTodaysDataDirectory
    % Make a data directory for all data generated today
    %
    % mpqc.tools.makeTodaysDataDirectory
    %
    % Purpose
    % Makes a directory that will contain all of the data for today in the user's
    % Desktop. If the directory already exists, only the path is returned. Gets
    % all information needed from user settings and mpqc.constants The directory
    % it makes is in the form "SYSTEMNAME_diagnostics\SYSTEMNAME__YYYY_MM_DD"
    %
    %
    % Inputs
    % none
    %
    % Outputs
    % dirPath - the full path to the folder. Empty if it could not be made.
    %
    % >> saveDir = mpqc.tools.makeTodaysDataDirectory
    %
    % saveDir =
    %
    % 'C:\Users\kiosk\Desktop\NeuroVision_diagnostics\NeuroVision__2024_07_03'
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2024


    rootDirPath = mpqc.tools.makeDataRootDirectory;

    if isempty(rootDirPath) || ~exist(rootDirPath,'dir')
        dirPath = [];
        return
    end

    s = mpqc.settings.readSettings;
    tDir = sprintf('%s__%s', s.microscope.name, datestr(now,'yyyy_mm_dd'));

    dirPath = fullfile(rootDirPath,tDir);

    if ~exist(dirPath,'dir')
        mkdir(dirPath);
    end

    if ~exist(dirPath,'dir')
        dirPath = [];
    end


end
