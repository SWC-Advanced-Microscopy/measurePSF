function [settings,allValid] = checkSettingsAreValid(settings)
    % Check that all settings that are read in are valid
    %
    % function [settings,allValid] = mpqc.settings.checkSettingsAreValid(settings)
    %
    % Purpose
    % Attempt to stop weird errors that could be caused by the user entering a weird setting.
    % This function *also* converts some values from cells to vectors, as reading from the
    % YAML creates unwanted cell arrays. Consequently, this function must be run after data
    % are read in. It is called by mpqc.settings.readSettings.
    %
    % Inputs
    % settings - The is the output of reading a settings file with mpqc.yaml.ReadYaml, but
    %          usually this function is called by mpqc.settings.readSettings directly.
    %
    %
    % Rob Campbell - SWC 2023
    %
    % See also:
    % mpqc.settings.readSettings
    % mpqc.settings.default_settings
    % mpqc.settings.settingsValuesTests
    %
    %
    %  Rob Campbell, SWC AMF

    allValid=true;
    [DEFAULT_SETTINGS,SETTINGS_TESTS] = mpqc.settings.default_settings;

    % Loop through everything
    f0 = fields(DEFAULT_SETTINGS);
    for ii = 1:length(f0);
        if ~isfield(SETTINGS_TESTS, f0{ii})
            fprintf('No tests for settings section "%s"\n', f0{ii})
            continue
        end

        f1 = fields(DEFAULT_SETTINGS.(f0{ii}));

        for jj = 1:length(f1)
            if ~isfield(SETTINGS_TESTS, f0{ii})
                fprintf('No tests for setting "%s.%s"\n', f0{ii},f1{jj})
                continue
            end

            tests = SETTINGS_TESTS.(f0{ii}).(f1{jj});
            if isempty(tests)
                continue
            end

            for kk = 1:length(tests)
                test = tests{kk};
                [settings,isValid]=test(settings,DEFAULT_SETTINGS,f0{ii},f1{jj});
                if isValid==false
                    allValid=false;
                end
            end

        end
    end

end
