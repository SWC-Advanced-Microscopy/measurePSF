function out = parseInputVariable(varargin)
    % Parse power and wavelength, and if required, depth and step size
    %
    % out = parseInputVariable('param1', val1, ...)
    %
    % Purpose
    % Recording functions need the power and wavelength, and sometimes depth and step
    % size, supplied by the user. The user may either do this by supplying input args as
    % parameter/value pairs or, if they do not, as interactive inputs that have a default
    % value. This function handles this. This function is called by the mpsf.record.
    % functions such as mpsf.record.uniform_slide, .lens_paper, and .PSF.
    %
    %
    % Inputs (optional param/val pairs)
    %  'wavelength' - Excitation wavelength of the laser. Defined in nm.
    %  'power' - Power at the sample. Defined in mW.
    %  'depthMicrons' - The number of microns over which to take a Z stack. Defined in um.
    %  'stepSize' - Step size between optical planes in a z-stack. Defined in um.
    %
    % Note: all inputs apart from stepSize are rounded to the nearest whole number.
    %
    %
    % Outputs
    % out - A structure containing the user's choices.
    % e.g.
    %  out.wavelength = 920;
    %  out.power = 20;
    %
    %
    % Isabell Whiteley, SWC 2024


    % Make the inputParser object
    params = inputParser;
    params.CaseSensitive = false; % So we do not have to be case sensitive

    % add parameters
    params.addParameter('wavelength', [], @(x) isnumeric(x));
    params.addParameter('power', [], @(x) isnumeric(x));
    params.addParameter('depthMicrons', [], @(x) isnumeric(x));
    params.addParameter('stepSize', [], @(x) isnumeric(x));

    % Parse the input arguments
    params.parse(varargin{:});

    % Extract the variables
    out.wavelength=params.Results.wavelength;
    out.power=params.Results.power;
    out.depthMicrons=params.Results.depthMicrons;
    out.stepSize=params.Results.stepSize;


    % Used to determine the identity of the calling function
    dStack = dbstack;


    % Interactively handle each input argument if it was not supplied as a param/val pair
    if isempty(params.Results.depthMicrons) && strcmp(dStack(2).file,'PSF.m')
        default=20;
        txt = sprintf('Please enter depth (um) [%d]: ',default);
        out.depthMicrons =  round(parseResponse(txt,default));
    end

    if isempty(params.Results.stepSize) && strcmp(dStack(2).file,'PSF.m')
        default=0.25;
        txt = sprintf('Please enter step size (um) [%0.3f]: ',default);
        out.stepSize = parseResponse(txt,default);
    end

    if isempty(params.Results.wavelength)
        default=920;
        txt = sprintf('Please enter wavelength (nm) [%d]: ',default);
        out.wavelength = round(parseResponse(txt,default));
    end

    if isempty(params.Results.power)
        default=20;
        txt = sprintf('Please enter power (mW) [%d]: ',default);
        out.power = round(parseResponse(txt,default));
    end



function response = parseResponse(promptString,default)
    % Conducts an interactive prompt to help the user choose a value

    response = [];
    while isempty(response)
        response = input(promptString,'s');
        if isempty(response)
            response = default;
        else
            response = str2num(response);
        end
   end

