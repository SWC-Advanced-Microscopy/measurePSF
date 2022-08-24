function reportFileSaveLocation(saveDir,fileStem)
	% Report where file is saved

    D = dir([fullfile(saveDir,fileStem),'*']);
    pathToTiff = fullfile(saveDir,D.name);
    fprintf('Saved data to %s\n', pathToTiff)

