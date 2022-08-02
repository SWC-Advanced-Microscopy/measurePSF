function imData=getCurrentImage
% Get the current image(s) from ScanImage
%
% function hSI = sibridge.getCurrentImage
%
% Purpose
% Returns the currently displayed images as a cell array. Each cell in
% the array is one channel. Returns empty if no ScanImage is present.
%
% Inputs
% None
%
% Outputs
% imData - Cell array of images obtained from ScanImage. Each cell is from a 
%          different channel. If ScanImage is not started or otherwise not 
%          present, then hSI will be empty. 
%
%
% Rob Campbell - Jan 2020


im=[];

hSI = sibridge.getSIobject;
if isempty(hSI)
	imData = [];
    return
end

if isempty(hSI.hDisplay.stripeDataBuffer{1})
    fprintf('No data in ScanImage stripeDataBuffer\n')
    return
end

%Pull data from all channels 
stripeDataBuffer = hSI.hDisplay.stripeDataBuffer;
roiData = stripeDataBuffer{1}.roiData{1};

nChannels = length(roiData.channels);
nAveFrames = length(stripeDataBuffer);

imData = {};
for ii = 1:nChannels
    tChan = stripeDataBuffer{1}.roiData{1}.imageData{ii}{1};
    tChan = repmat(tChan,1,1,nAveFrames);
    size(tChan)
    for jj = 1:nAveFrames
        tChan(:,:,jj) = stripeDataBuffer{jj}.roiData{1}.imageData{ii}{1};

    end
    imData{ii} = mean(tChan,3);
end

