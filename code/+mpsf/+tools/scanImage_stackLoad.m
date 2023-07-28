function [imStack,metadata] = scanImage_stackLoad(fileName)
% load a z-stack from ScanImage for analysis return also in a structure useful metadata
%
%
% function imStack = mpsf.tools.scanImage_stackLoad(fileName)
%
% Purpose
% Return z stack and metadata. Subtracts any offset if needed.
%
% Inputs
% fileName - string defining the file name to load
%
% Outputs
% imStack - 3D stack
% metadata - useful metadata from scanimage header
% 
% Example
% [imS,metadata] = mpsf.tools.scanImageStackLoad('Bead_*.tif')
%
% 
%
% Rob Campbell - SWC 2022


    imStack = [];
    metadata = [];

    if ~exist(fileName,'file')
        fprintf('%s does not exist. Not loading.\n',fileName)
        return
    end

    imStack = mpsf.tools.load3Dtiff(fileName);



    % Pull out the voxel size and other useful information
    metadata=sibridge.readTifHeader(fileName);
    if isempty(metadata)
        fprintf('\n\n *** TIFF header is missing ScanImage meta-data. Is this a ScanImage TIFF? *** \n\n')
        return
    end


    % subtract the offset if needed
    savedChans = metadata.channelSave; % The acquired channels
    offset = metadata.channelOffset(savedChans); % Use acquired channels to index offsets
    offsetSubtracted = metadata.channelSubtractOffset;


    %expand offsets so they are the same length as the image data
    offset = repmat(offset,1,size(imStack,3)/length(offset));

    offsetSubtracted = repmat(offsetSubtracted,1,size(imStack,3)/length(savedChans));

    for ii=1:size(imStack,3)
        if offsetSubtracted(ii) == 0
            imStack(:,:,ii) = imStack(:,:,ii)-offset(ii);
        end
    end


    % Calculate the FOV
    fov=diff(metadata.imagingFovUm(1:2));
    metadata.micsPerPixelXY = fov/metadata.linesPerFrame;
