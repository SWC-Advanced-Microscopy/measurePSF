function uniform_slide_test(varargin)
    % Image uniform slide
    %
    % function mpsf.record.uniform_slide(laser_power_in_mW,laser_wavelength)
    %
    % User must supply power and wavelengths as integers.
    % This is for logging purposes. If the user fails to do this,
    % they are prompted at CLI. The order of the two arguments
    % does not matter.
    %
    % e.g.
    % >> mpsf.record.uniform_slide
    % >> mpsf.record.uniform_slide(10,920)
    % >> mpsf.record.uniform_slide(920,10)
    %
    %
    % Rob Campbell, SWC 2022


    out =  mpsf.record.parseInputVariable(varargin{:});
    wavelength=out.wavelength;
    % power=out.power;

    fprintf('wavelength is:\n ')
    disp(wavelength)

    % fprintf('power is:\n')
    % disp(power)
