function microscope = loadMicroscopeDescription
    % load microscope description file and return as a structure
    %
    %



    microscope = [];


    yamlName = 'microscope_description.yml';

    pathToFile = which(yamlName);

    if isempty(pathToFile)
        fprintf('Found no microscope description YAML file\n')
        fprintf('Consider making one with  mpsf.tools.createBlankMicroscopeDescription')
        return
    end


    microscope = mpsf.yaml.ReadYaml(pathToFile);

    % Go through the structure and wipe any fields that the user has not modified
    tFields = fields(microscope);
    for ii=1:length(tFields)
        tData = microscope.(tFields{ii});

        if contains(tData, {'ENTER','MANUFACTURER','MODEL','ZZ'})
            microscope.(tFields{ii}) = '';
        end
    end

