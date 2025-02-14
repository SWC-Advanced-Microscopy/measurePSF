function postAcqTasks(saveDir,fileStem)
    % Report the location the file was saved to and copy the system's MPSF settings
    % file to that location for logging purposes
    %
    % Inputs
    % saveDir - path to which data were saved
    % fileStem - the name of the saved file
    %
    % Rob Campbell, SWC AMF, initial commit 2025


    % Report where the file was saved
    mpsf.tools.reportFileSaveLocation(saveDir,fileStem)

    % Save system settings to this location
    settingsFilePath = mpsf.settings.findSettingsFile;
    copyfile(settingsFilePath, saveDir)
