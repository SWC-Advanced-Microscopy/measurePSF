classdef (Abstract) constants
    % Return constants that will be used across multiple functions in measure PSF

    methods(Static)

        function out = rootDir
            % All data directories will stored in this directory that will be
            % placed in the Desktop
            s = mpqc.settings.readSettings;
            out = sprintf('%s_diagnostics',s.microscope.name);
        end

    end % static methods

end % clasdef
