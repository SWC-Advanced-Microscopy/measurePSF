function [imStack,metadata] = scanImage_stackLoad(fileName)
% load a z-stack from ScanImage for analysis return also in a structure useful metadata
%
%
% function imStack = mpsf_tools.scanImage_stackLoad(fileName)
%
% Purpose
% Return z stack and metadata. Subtracts any offset.
%
% Inputs
% fileName - string defining the file name to load
%
% Outputs
% imStack - 3D stack
% metadata - useful metadata from scanimage header
% 
% Example
% [imS,metadata] = mpsf_tools.scanImageStackLoad('Bead_*.tif')
%
% 
%
% Rob Campbell - SWC 2022


	imStack = [];
	metadata = [];

    if ~exist(fileName,'file')
        fprintf('%s does not exist. Not loading.\n',obj.fname)
        return
    end

	imStack = mpsf_tools.load3Dtiff(fileName);


    % Pull out the voxel size and other useful information
	metadata=sibridge.readTifHeader(fileName);
    if isempty(metadata)
        fprintf('\n\n *** TIFF header is missing ScanImage meta-data. Is this a ScanImage TIFF? *** \n\n')
    	return
    end


    % subtract the offset
    chans = metadata.channelSave; % The acquired channels
    offset = metadata.channelOffset(chans); % Use acquired channels to index offsets
	%expand offsets so they are the same length as the image data
    offset = repmat(offset,1,size(imStack,3)/length(offset));
    for ii=1:size(imStack,3)
    	imStack(:,:,ii) = imStack(:,:,ii)-offset(ii);
    end


    % Calculate the FOV
    fov=diff(metadata.imagingFovUm(1:2));
	metadata.micsPerPixelXY = fov/metadata.linesPerFrame;
