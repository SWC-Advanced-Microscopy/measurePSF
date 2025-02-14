classdef (Abstract) settingsValuesTests

    % Tests associated with default_settings
    %
    % mpqc.settings.settingsValuesTests
    %
    % Purpose
    % Defines generic tests that can be combined to ensure values in settings file reasonable.
    %
    %
    % See mpqc.settings.checkSettingsAreValid for how these methods are used.
    % See mpqc.settings.default_settings for where tests are specified.
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2023


    %%
    % The following methods apply checks and replace bad values with defaults.
    methods(Static)

        % * How the following methods work
        % In each case the following methods test some aspect of value in the structure "actualStruct".
        % The value itself is always addressed as "actualStruct.(sectionName).fieldName". This is done
        % in the function "mpqc.settings.checkSettingsAreValid". If the value does not pass then the
        % default value from the structure "defaultStruct" is used to replace the value that was present.
        % A message is displayed to the CLI. The second output argument of each method, "isValid" is
        % true if no replacement had to be done and false otherwise. This is used by the function
        % "mpqc.settings.checkSettingsAreValid" to determine whether any settings in the YAML at all
        % needed replacing.

        function [actualStruct,isValid] = check_isCellArrayOfStrings(actualStruct,defaultStruct,sectionName,fieldName)
            isValid = true;
            if ~iscell(actualStruct.(sectionName).(fieldName))
                fprintf('-> %s.%s should be a cell array of strings. Returning an empty array!.\n', ...
                    sectionName,fieldName)
                actualStruct.(sectionName).(fieldName) = [];
                isValid = false;
            elseif ~all(cellfun(@(x) ischar(x), actualStruct.(sectionName).(fieldName)))
                fprintf('-> %s.%s should be a cell array of strings. Returning an empty array!.\n', ...
                    sectionName,fieldName)
                actualStruct.(sectionName).(fieldName) = [];
                isValid = false;
            end
        end

        function [actualStruct,isValid] = check_isnumeric(actualStruct,defaultStruct,sectionName,fieldName)
            isValid = true;
            if ~isnumeric(actualStruct.(sectionName).(fieldName))
                fprintf('-> %s.%s should be a number. Setting it to %d.\n', ...
                    sectionName,fieldName,defaultStruct.(sectionName).(fieldName))
                actualStruct.(sectionName).(fieldName) = defaultStruct.(sectionName).(fieldName);
                isValid = false;
            end
        end


        function [actualStruct,isValid] = check_ischar(actualStruct,defaultStruct,sectionName,fieldName)
            isValid = true;
            if isempty(actualStruct.(sectionName).(fieldName))
                return
            end
            if ~ischar(actualStruct.(sectionName).(fieldName))
                fprintf('-> %s.%s should be a character. Setting it to %s.\n', ...
                    sectionName,fieldName,defaultStruct.(sectionName).(fieldName))
                actualStruct.(sectionName).(fieldName) = defaultStruct.(sectionName).(fieldName);
                isValid = false;
            end
        end


        function [actualStruct,isValid] = check_isscalar(actualStruct,defaultStruct,sectionName,fieldName)
            isValid = true;
            if ~isnumeric(actualStruct.(sectionName).(fieldName)) || ...
                 ~isscalar(actualStruct.(sectionName).(fieldName))
                fprintf('-> %s.%s should be a scalar. Setting it to %d.\n', ...
                    sectionName,fieldName,defaultStruct.(sectionName).(fieldName))
                actualStruct.(sectionName).(fieldName) = defaultStruct.(sectionName).(fieldName);
                isValid = false;
            end
        end


        function [actualStruct,isValid] = check_isZeroOrGreaterScalar(actualStruct,defaultStruct,sectionName,fieldName)
            isValid = true;
            if ~isnumeric(actualStruct.(sectionName).(fieldName)) || ...
                ~isscalar(actualStruct.(sectionName).(fieldName)) || ...
                    actualStruct.(sectionName).(fieldName)<0
                fprintf('-> %s.%s should be a number. Setting it to %d.\n', ...
                    sectionName,fieldName,defaultStruct.(sectionName).(fieldName))
                actualStruct.(sectionName).(fieldName) = defaultStruct.(sectionName).(fieldName);
                isValid = false;
            end
        end


        function [actualStruct,isValid] = check_isLogicalScalar(actualStruct,defaultStruct,sectionName,fieldName)
            isValid = true;
            if ~isscalar(actualStruct.(sectionName).(fieldName)) || ...
                (actualStruct.(sectionName).(fieldName) ~= 0 && ...
                actualStruct.(sectionName).(fieldName) ~= 1)
                fprintf('-> %s.%s should be a logical scalar. Setting it to %d.\n', ...
                    sectionName,fieldName,defaultStruct.(sectionName).(fieldName))
                actualStruct.(sectionName).(fieldName) = defaultStruct.(sectionName).(fieldName);
                isValid = false;
            end
        end


        function [actualStruct,isValid] = check_isIPaddress(actualStruct,defaultStruct,sectionName,fieldName)
            isValid = true;
            % Check if it's a character array
            if ~ischar(actualStruct.(sectionName).(fieldName))
                fprintf('-> %s.%s should be a scalar. Setting it to %s.\n', ...
                    sectionName,fieldName,defaultStruct.(sectionName).(fieldName))
                actualStruct.(sectionName).(fieldName) = defaultStruct.(sectionName).(fieldName);
                isValid = false;
                return
            end

            % Then make sure the string is a valid IP address (or 'localhost')
            if ~strcmp(actualStruct.(sectionName).(fieldName),'localhost') && ...
                isempty(regexp(actualStruct.(sectionName).(fieldName),'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'))
                fprintf('-> %s.%s should be a valid IP address. Setting it to %s.\n', ...
                    sectionName, fieldName, defaultStruct.(sectionName).(fieldName))
                actualStruct.(sectionName).(fieldName) = defaultStruct.(sectionName).(fieldName);
                isValid = false;
            end

        end
    end % check methods


    %%
    % The following methods perform conversions or other house-keeping tasks, not checks
    methods(Static)

        function [actualStruct,isValid] = convert_cell2mat(actualStruct,~,sectionName,fieldName)
            % Used to turn a cell array into a matrix. This is because arrays from a YAMLs are read in as
            % cell arrays and sometimes they need to be matrices. This method is called in
            % mpqc.settings.checkSettingsAreValid and we select when it is to be run by defining this in
            % mpqc.settings.default_settings
            isValid = true;
            actualStruct.(sectionName).(fieldName) = cell2mat(actualStruct.(sectionName).(fieldName));
        end

    end % Methods

end % classdef
