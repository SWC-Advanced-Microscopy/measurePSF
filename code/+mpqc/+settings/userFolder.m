function userDir = userFolder
    % Return path to user's home folder as a string
    %
    % function userDir = mpqc.settings.userFolder
    %
    % Purpose
    % Return path to user's home folder on Windows or Unix systems. Returns
    % empty if it fails to find a home folder for some reason.
    %
    % Inputs
    % none
    %
    % Outputs
    % userDir - string defining the path to the user's home folder.
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2022


    if ispc
        %From https://uk.mathworks.com/matlabcentral/fileexchange/15885-get-user-home-directory
        userDir = winqueryreg('HKEY_CURRENT_USER',...
                ['Software\Microsoft\Windows\CurrentVersion\' ...
                 'Explorer\Shell Folders'],'Personal');
    else
        userDir = '~';
    end

    % Just in case
    if ~exist(userDir)
        userDir = [];
    end

end % userFolder
