classdef silinker < handle
    % Linking to the ScanImage API
    %
    % Performs some useful operations as well as exposing the ScanImage API
    %
    %
    % sitools.silinker

    properties (Hidden)
        scanimageObjectName = 'hSI' % If connecting to ScanImage look for this variable in the base workspace
        hSI % The ScanImage API attaches here
        listeners = {} % Reserved for listeners we might make

    end % Close hidden methods

    properties
        linkSucceeded % true if SI connected
    end

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
                obj.linkSucceeded = false;
                return
            end

            obj.hSI=API; % Make composite object
            obj.linkSucceeded = true;
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
            if contains(scannerType,'rg') || strcmp('resonant',scannerType)
                scannerType = 'resonant';
            elseif strcmp('gg',scannerType)
                scannerType='linear';
            else
                fprintf('Unknown scanner type %s\n', scannerType)
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


        function setZSlices(obj,nSlices)
            % Set the number of slices to acquire in a z-stack
            % Handles differences across versions of SI.
            if obj.versionGreaterThan('2020')
                obj.hSI.hStackManager.numSlices=nSlices;
                obj.hSI.hStackManager.numVolumes = 1;
            else
                obj.hSI.hStackManager.numSlices=nSlices;
                obj.hSI.hFastZ.numVolumes=nSlices;
            end
        end % setZSlices


        function chanName = getSaveChannelName(obj)
            % Return the name of the channel being saved as a string
            %
            % Purpose
            % We want to log to the file name the channel name being saved.
            % If more than one channel has been selected for saving we will
            % return empty and prompt the user to select only one channel
            % to save.
            %
            % Outputs
            % chanName - string defining the name of the channel to save.
            %       If more than one channel is being saved it returns empty.

            if length(obj.hSI.hChannels.channelSave) > 1
                fprintf('Select just one channel to save\n')
                chanName = [];
                return
            end
            chanName = obj.hSI.hChannels.channelName{obj.hSI.hChannels.channelSave};
            chanName = strrep(chanName,' ', '_');
        end % getSaveChannelName


        function turnOffPMTs(obj)
            % Turn off all PMTs
            obj.hSI.hPmts.powersOn = obj.hSI.hPmts.powersOn*0;
        end % turnOffPMTs


        function turnOnPMTs(obj)
            % Turn on all PMTs
            obj.hSI.hPmts.powersOn = ones(1,length(obj.hSI.hPmts.powersOn));
        end % turnOffPMTs


        function setPMTgains(obj,gain)
            % Set gains of all PMTs
            %
            % Inputs
            % gain - If a scalar, the same gain is applied to all PMTs. If a vector
            %      with the same length as the number of PMTs, we set each PMT gain
            %      to the value it corresponds to in the vector.

            if isempty(gain)
                return
            end

            if length(gain)==1
                obj.hSI.hPmts.gains = repmat(gain,1,4);
            elseif length(obj.hSI.hPmts.gains) == length(gain)
                obj.hSI.hPmts.gains = gain(:)';
            end
        end % turnOffPMTs


        function zFactStr = returnZoomFactorAsString(obj)
            % Return the zoom factor as a neatly formatted string for file names.
            %
            % Inputs
            % none
            %
            % Outputs
            % Returns a string specifying the current ScanImage zoom factor. The string
            % is used for building file names so the '.' is replaced with '-'

            zFactStr = strrep(num2str(obj.hSI.hRoiManager.scanZoomFactor),'.','-');

        end % returnZoomFactorAsString


    end % Close methods


end % Close classdef
