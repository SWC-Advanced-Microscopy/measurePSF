function out = parseInputVariable(varargin)

    % Parse power and wavelength for all functions and depth/step for psf
    % 
    % Parse depth in microns and step size for PSF function
    % 
    % Purpose
    % Recording functions need the power and wavelength supplied by the user. The user
    % may either do this as input args or, if they do not, as interactive inputs, and finally as a default value. 
    % This function handles this. The can supply the arguments in any order.
    % See mpsf.record.uniform_slide and mpsf.record.lens_paper for examples
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