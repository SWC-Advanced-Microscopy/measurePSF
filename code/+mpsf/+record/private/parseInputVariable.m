function out = parseInputVariable(varargin)
    % Parse power and wavelength, and if required, depth and step size
    % 
    % Parse depth in microns and step size for PSF function
    % 
    % Purpose
    % Recording functions need the power and wavelength, and sometimes depth and step size, supplied by the user. The user
    % may either do this as input args or, if they do not, as interactive inputs, and finally as a default value. 
    % This function handles this. The can supply the arguments in any order.
    % See mpsf.record.uniform_slide, mpsf.record.lens_paper, and mpsf.record.PSF for examples
    %
    % Inputs:
    % wavelength (in nm, default value 920nm)
    % power (in mW, defauly value 20mW)
    % depthMicrons (in um, default value 20um)
    % stepSize (in um, defualt value 0.25um)
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

    d=dbstack;
    d.file;

    if isempty(params.Results.depthMicrons) &&  strcmp(d(2).file,'PSF.m')
        default=20;
        response = [];
        while isempty(response)
            response = input(sprintf('Please enter depth (um) [%d]: ',default),'s');
            if isempty(response)
                response = default;
            else
                response = str2num(response);
            end
        end
        out.depthMicrons = response;
    end

    if isempty(params.Results.stepSize) &&  strcmp(d(2).file,'PSF.m')
        default=0.25;
        response = [];
        while isempty(response)
            response = input(sprintf('Please enter step size (um) [%0.3f]: ',default),'s');
            if isempty(response)
                response = default;
            else
                response = str2num(response);
            end
        end
        out.stepSize = response;
    end

    if isempty(params.Results.wavelength)
        default=920;
        response = [];
        while isempty(response)
            response = input(sprintf('Please enter wavelength (nm) [%d]: ',default),'s');
            if isempty(response)
                response = default;
            else
                response = str2num(response);
            end
        end
        out.wavelength = round(response);
    end

   if isempty(params.Results.power)
       default=20;
       response = [];
       while isempty(response)
           response = input(sprintf('Please enter power (mW) [%d]: ',default),'s');
           if isempty(response)
               response = default;
           else
               response = str2num(response);
           end 
       end 
       out.power = round(response);
   end 