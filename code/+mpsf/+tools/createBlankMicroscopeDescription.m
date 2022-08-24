function varargout = createBlankMicroscopeDescription(overwrite)
    % Create a blank YAML file that describes the microscope hardware
    %
    % function pathToFile = mpsf.tools.createBlankMicroscopeDescription
    %
    % Purpose
    % Generate a blank microscope description YAML file. This will be placed
    % at the top of the MATLAB path, but can be moved later to any location
    % within the MATLAB path. The file contains a description of the key
    % hardware that can not be obtained from ScanImage.
    %
    % INSTRUCTIONS
    % Run this function then edit the file and move it to a better location
    % if appropriate. Fields that are not altered will not be read so you can
    % leave unused PMT and amplifier channels with the default text. Avoid using
    % funny characters (', ", _ , ^, (, ), ,, :) in the text you enter as this is
    % may cause problems downstream. Remember not to remove existing commas and colons.
    %
    %
    % Inputs
    % overwrite - false by default
    %
    %
    % Outputs
    % pathToFile - optionally return the path to the created file
    %
    %
    % Rob Campbell - SWC, 2022


    if nargin<1
        overwrite = false;
    end

    yamlName = 'microscope_description.yml';

    if exist(yamlName,'file')>0
        % The file already exists
        if overwrite==false
            % Do not overwrite unless user said so
            fprintf('\n Existing microscope settings file found at %s\n', which(yamlName))
            fprintf(' To replace it run: mpsf.tools.createBlankMicroscopeDescription(true)\n')
            return
        else
            % Overwrite the existing file
            pathToFile = which(yamlName);
            fprintf('\nOverwriting microscope settings file at %s\n', which(yamlName))
        end
    else
        % No file exists so choose a loction in the path to save to
        p=strsplit(path,':');
        saveDir = p{1};
        pathToFile = fullfile(saveDir,yamlName);
        fprintf('Creating blank microscope settings file at %s\n', pathToFile)
        fprintf('** If this is not a good, please move it to a better place in the MATLAB path. **\n')
    end



    % Blank settings
    settings.microscope_name = 'ENTER MICROSCOPE NAME HERE';
    settings.objective = 'MANUFACTURER ZZx NA=ZZ';
    settings.laser = 'MANUFACTURER_NAME MODEL_NAME';
    settings.modulator = 'MANUFACTURER_NAME MODEL_NAME';

    settings.PMT_channel_1 = 'MANUFACTURER_NAME MODEL_NAME';
    settings.PMT_channel_2 = 'MANUFACTURER_NAME MODEL_NAME';
    settings.PMT_channel_3 = 'MANUFACTURER_NAME MODEL_NAME';
    settings.PMT_channel_4 = 'MANUFACTURER_NAME MODEL_NAME';

    settings.amplifier_channel_1 = 'MANUFACTURER_NAME MODEL_NAME';
    settings.amplifier_channel_2 = 'MANUFACTURER_NAME MODEL_NAME';
    settings.amplifier_channel_3 = 'MANUFACTURER_NAME MODEL_NAME';
    settings.amplifier_channel_4 = 'MANUFACTURER_NAME MODEL_NAME';



    mpsf.yaml.WriteYaml(pathToFile,settings);

    fprintf('File created. Please edit the file to fill in details for your system.\n')

    if nargout>0
        varargout{1} = pathToFile;
    end
