function mkdirname = makeDesktopDirectory(dirname)
	% Make a directory in the user's Desktop called dirname
	%
	% function mkdirname = makeDesktopDirectory(dirname)
    %
    % Purpose
    % Creates a directory of a given name in the user's Desktop folder.
    %
    % Inputs
    % dirname - String defining a directory name to make.
	%
    % Outputs
    % mkdirname - Full path of the created directory name.
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2023


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

