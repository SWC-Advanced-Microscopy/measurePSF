classdef silinker < handle
    % Linking to the ScanImage API
    %
    % 
    %
    % 
    % sitools.silinker
    
    properties (Hidden)
        scanimageObjectName = 'hSI' % If connecting to ScanImage look for this variable in the base workspace
        hSI % The ScanImage API attaches here
        listeners = {} % Reserved for listeners we might make
    end % Close hidden methods
    
    
    methods
        
        function obj = silinker(connectToSI)
            % By default connect to ScanImage on startup
            if nargin<1
                connectToSI=true;
            end

            if connectToSI
                obj.linkToScanImageAPI;
            end

        end % Constructor
        
        
        function delete(obj)
            obj.hSI=[];
        end % Destructor
        
        function success = linkToScanImageAPI(obj)
            % Link to ScanImage API by importing from base workspace and
            % copying handling to obj.hSI

            success=false;


            API = sibridge.getSIobject;
            if isempty(API)
                fprintf('ScanImage not found, unable to link to it.\n')
                return
            end

            obj.hSI=API; % Make composite object
            success=true;
        end % linkToScanImageAPI

                    
        function reportError(~,ME)
            % Reports error from error structure, ME
            fprintf('ERROR: %s\n',ME.message)
            for ii=1:length(ME.stack)
                 fprintf(' on line %d of %s\n', ME.stack(ii).line,  ME.stack(ii).name)
            end
            fprintf('\n')
        end % reportError


        function isGreater = versionGreaterThan(obj,verToTest)
            % Return true if the current ScanImage version is newer than that defined by string verToTest
            % 
            % SIBT.versionGreaterThan(obj,verToTest)
            %
            % Inputs
            % verToTest - should be in the format '5.6' or '5.6.1' or
            % '2020.0'
            %
            % Note: this method does not know what to do with the update
            % mumber from SI Basic. So 2020.1 is OK but 2020.1.4 won't 
            % produce correct results
 
            isGreater = nan;
            if ~ischar(verToTest)
                return
            end

            % Add '.0' if needed
            if length(strfind(verToTest,'.'))==0
                verToTest = [verToTest,'.0'];
            end

            % Turn string into a number
            verToTestAsNum = str2num(strrep(verToTest,'.',''));

            % Current version
            curVersion = [obj.hSI.VERSION_MAJOR,obj.hSI.VERSION_MINOR];
            if ischar(curVersion(1))
                % Likely this a free release
                curVersionAsNum = str2num(strrep(curVersion,'.',''));
            else
                % Likely this is Basic or Premium
                curVersionAsNum = curVersion(1)*10 + curVersion(2);
            end

            isGreater = curVersionAsNum>verToTestAsNum;
        end % versionGreaterThan


        function scannerType = scannerType(obj)
            % Since SI 5.6, scanner type "resonant" is returned as "rg"
            % This method returns either "resonant" or "linear"
            scannerType = lower(obj.hSI.hScan2D.scannerType);
            if strcmpi('RG',scannerType) || strcmpi('resonant',scannerType) 
                scannerType = 'resonant';
            elseif strcmpi('GG',scannerType)
                scannerType='linear';
            end 
        end % scannerType

        function acquireAndWait(obj,block)
            % Start a Grab acquisition and block until SI completes it. 

            if nargin<2
                block=true;
            end

            obj.hSI.startGrab % Acquire

            if ~block
                return
            end
            while 1
                if strcmp(obj.hSI.acqState,'idle') %Break when finished
                    break
                end
                pause(0.5)
            end % while
        end % acquireAndWait

    end % Close methods
    
    
end % Close classdef