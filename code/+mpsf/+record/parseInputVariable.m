function out = parseInputVariable(varargin)

    % Parse laser power and wavelength for all record functions
    % Parse depth in microns and step size for PSF function
   
    % Purpose
    % Recording functions need the power and wavelength supplied by the user. The user
    % may either do this as input args or, if they do not, as interactive inputs, and finally as a default value. 
    % This function handles this. The can supply the arguments in any order.
    % See mpsf.record.uniform_slide and mpsf.record.lens_paper for examples
    %
    %
    % Rob Campbell and Isabell Whiteley

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
       %ASK QUESTION
       default=20;
       response = [];
       while isempty(response)
           response = input(sprintf('Please enter depth (um) [20]: '),'s');
           if isempty(response)
               response = default;
           else
               [response,tf] = str2num(response);
               if tf==1 && isnumeric(response)
                   response = response;
               else
                   response = [];
               end
           end 
       end 
       out.depthMicrons = response;
   end 

    if isempty(params.Results.stepSize) &&  strcmp(d(2).file,'PSF.m')
       %ASK QUESTION
       default=0.25;
       response = [];
       while isempty(response)
           response = input(sprintf('Please enter step size (um) [0.25]: '),'s');
           if isempty(response)
               response = default;
           else
               [response,tf] = str2num(response);
               if tf==1 && isnumeric(response)
                   response = response;
               else
                   response = [];
               end
           end 
       end 
       out.stepSize = response;
   end 

   if isempty(params.Results.wavelength)
       %ASK QUESTION
       default=920;
       response = [];
       while isempty(response)
           response = input(sprintf('Please enter wavelength (nm) [920]: '),'s');
           if isempty(response)
               response = default;
           else
               [response,tf] = str2num(response);
               if tf==1 && isnumeric(response)
                   response = response;
               else
                   response = [];
               end
           end 
       end 
       out.wavelength = round(response);
   end 

   if isempty(params.Results.power)
       %ASK QUESTION
       default=20;
       response = [];
       while isempty(response)
           response = input(sprintf('Please enter power (mW) [20]: '),'s');
           if isempty(response)
               response = default;
           else
               [response,tf] = str2num(response);
               if tf==1 && isnumeric(response)
                   response = response;
               else
                   response = [];
               end
           end 
       end 
       out.power = round(response);
   end 

    
 % fprintf('wavelength is:\n');
 %    disp(out.wavelength);
 % 
 % 
 % fprintf('power is:\n');
 %    disp(out.power);