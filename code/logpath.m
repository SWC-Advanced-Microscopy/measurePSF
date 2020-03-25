function tPath=logpath
    % function tPath=logpath
    %
    % Purpose
    % Return path to which log information will be saved
    % e.g. on a Windows machine this will be the current user's Desktop.
    % Works on all platforms
    %
    % Inputs
    % None
    %
    % Outputs
    % tPath - path to which data will be saved


    
    if ispc
        % On Windows return the path to the User's Desktop
        [~,userPath] = system('echo %USERPROFILE%');
        userPath = strtrim(userPath);
        tPath = fullfile(userPath,'Desktop');

    elseif ismac
        % Macs
        tPath='~/Desktop';

    elseif isunix
        % Because we've already done Macs this is Linux

        tPath-'~'; % In case there is no desktop folder in this distro
    end
