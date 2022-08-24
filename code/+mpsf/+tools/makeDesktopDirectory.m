function mkdirname = makeDesktopDirectory(dirname)
	% Make a directory in the user's Desktop called dirname
	%
	% function mkdirname = makeDesktopDirectory(dirname)
	%

    % TODO == we need to copy microscope settings file to this directory

	success = false;
	mkdirname = [];

    [~, userdir] = system('echo %USERPROFILE%');
    tmp=regexp(userdir,'([\d\w:\\]*)','tokens');
    userdir=tmp{1}{1};

    if ~exist(userdir,'dir')
        fprintf('Can not find user directory: %s\n', userdir)
        return
    end

    mkdirname = fullfile(userdir,'Desktop', dirname);

    if ~exist(mkdirname,'dir')
        mkdir(mkdirname)
    end

    if ~exist(mkdirname,'dir')
        fprintf('Can not access or create directory %s\n', mkdirname)
        mkdirname = [];
    end

