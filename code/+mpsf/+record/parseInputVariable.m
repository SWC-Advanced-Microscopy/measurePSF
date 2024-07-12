function out = parseInputVariable(varargin)

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


      % Make the inputParser object
    params = inputParser;
    params.CaseSensitive = false; % So we do not have to be case sensitive
    % add parameters
    params.addParameter('wavelength', [], @(x) isnumeric(x));
    params.addParameter('power', [], @(x) isnumeric(x));
    params.addParameter('depthMicrons', [], @(x) isnumeric(x));
    params.addParameter('stepSize', 0.25, @(x) isnumeric(x));

    % Parse the input arguments
    params.parse(varargin{:});

    % Extract the variables
    out.wavelength=params.Results.wavelength;
    out.power=params.Results.power;
    out.depthMicrons=params.Results.depthMicrons;
    out.stepSize=params.Results.stepSize;



    d=dbstack;
    d.file;


   %  if isempty(params.Results.depthMicrons) &&  strcmp(d(2).file,'PSF.m')
   %      %ASK QUESTION
   %      default=20;
   %      response = input(sprintf('Please enter depth to image (default = %d microns): ', default));
   %      out.depthMicrons = response;
   %      if iesmpty(response)
   %          out.depthMicrons = params.Results.depthMicrons;
   %      end
   %  end
   % 
   % if isempty(params.Results.stepSize) &&  strcmp(d(2).file,'PSF.m')
   %      %ASK QUESTION
   %      default=0.25;
   %      response = input(sprintf('Please enter step size (default = %d microns): ', default));
   %      out.stepSize = response;
   %      if iesmpty(response)
   %         out.stepSize = params.Results.stepSize;
   %      end
   %  end

    if isempty(params.Results.wavelength)
        %ASK QUESTION
        default=920;
        response = [];
        while isempty(response) 
            response = input(sprintf('Please enter wavelength (nm) [920]: '),'s');
            response = str2double(response);
             % response = str2num(response);
            if isempty(response)
                response = default;
            end
           if isnumeric(response)==0
               response = [];
           end
        end
        out.wavelength = response;
    end


    % if isempty(params.Results.power)
    %     %ASK QUESTION
    %     % default=0.25;
    %     response = input(sprintf('Please enter power (mW): '));
    %     out.Results.power = response;
    %     % params.Results.power = response;
    %     % if iesmpty(response)
    %         % params.Results.depthMicrons = default;
    %     % end
    % end

    
 fprintf('wavelength is:\n');
    disp(out.wavelength);

