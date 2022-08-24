function [laser_power_in_mW, laser_wavelength] = parsePowerAndWavelength(varargin)
    % Parse laser power and wavelength from record functions
    %
    % function [laser_power_in_mW, laser_wavelength] = parsePowerAndWavelength(varargin)
    %
    % Purpose
    % Recording functions need the power and wavelength supplied by the user. The user
    % may either do this as input args or, if they do not, as interactive inputs. This
    % function handles this. The can supply the arguments in any order.
    % See mpsf.record.uniform_slide and mpsf.record.lens_paper for examples
    %
    %
    % Rob Campbell


    if nargin<2
        doInteractive = true;
    else
        doInteractive = false;
    end


    if doInteractive
        [laser_power_in_mW, laser_wavelength] = ineractive_nm_mW();
    else
        [laser_power_in_mW, laser_wavelength] = power_wavelength_from_args(varargin);
    end


    laser_power_in_mW = round(laser_power_in_mW);
    laser_wavelength = round(laser_wavelength);



    % Internal functions follow
    function [laser_power_in_mW, laser_wavelength] = power_wavelength_from_args(varargin)
        IN = sort(cell2mat(varargin{1}));
        laser_power_in_mW = IN(1);
        laser_wavelength = IN(2);


    function [laser_power_in_mW, laser_wavelength] = ineractive_nm_mW()

        laser_power_in_mW = [];
        while isempty(laser_power_in_mW)
            txt = input('Please enter laser power in mW: ','s');
            laser_power_in_mW = str2num(txt);
        end

        laser_wavelength = [];
        while isempty(laser_wavelength)
            txt = input('Please enter laser wavelength in nm: ','s');
            laser_wavelength = str2num(txt);
        end
