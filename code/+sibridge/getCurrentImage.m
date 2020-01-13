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
    return
end

if isempty(hSI.hDisplay.stripeDataBuffer{1})
    fprintf('No data in ScanImage stripeDataBuffer\n')
    return
end

%Pull data from all channels 
roiData=hSI.hDisplay.stripeDataBuffer{1}.roiData{1};

imData = {};
for ii = 1:length(roiData.channels)
    imData{ii} = roiData.imageData{ii}{1};
end

