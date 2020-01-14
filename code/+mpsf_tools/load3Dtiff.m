function [imageStack,imageInfo]=load3Dtiff(FileName,varargin)
% Load multi-image tiff from disk 
% 
%function [imageStack,imageInfo]=load3Dtiff(FileName,'param1','val1','param2','val2',...)
%
% PURPOSE
% Load a 3D stack (e.g. those exported by ImageJ) as a 3-D matrix. 
% If you have multiple channels then you may need to separate these
% manually since ImageJ will interleave them. Automatically loads in
% parallel if a parpool is already open (unless supressParallelLoading is true). 
% 
%
% INPUTS (requried)
% FileName - a string specifying the full path to the tif you wish
%   to import.  
%
% INPUTs (optional)
% 'frames' - By default the function loads all frames. If
%   frames is present in loads only the frames defined by this
%   vector. e.g. if frames is 1:10 then the first ten frames are loaded only. 
% 'padMissingFrames'  - false by default. If true and the user asked for, say,
%               frames [1,5,10], then the function returns an array of size 10
%               in the 3rd dimension. All data will be zeros apart from layers 
% 'supressParallelLoading' - false by default
% 'outputType' - the type of the output data. 'single' by default.
%
%
% OUTPUTS
% imageStack - a 3-D matrix of frames extracted from the file. 
% imageInfo - lots of information about the images [optional]
%
%
%
%
% Rob Campbell, March, 2009 
% last updated : March, 2016 


%Parse optional arguments
params = inputParser;
params.CaseSensitive = false;
params.addParamValue('frames', [], @(x) isnumeric(x) && isscalar(x) || isvector(x));
params.addParamValue('supressParallelLoading', false, @(x) islogical(x) || x==0 || x==1);
params.addParamValue('padMissingFrames', false, @(x) islogical(x) || x==0 || x==1);
params.addParamValue('outputType', 'single', @(x) ischar(x) );

params.parse(varargin{:});

frames=params.Results.frames;
supressParallelLoading=params.Results.supressParallelLoading;
padMissingFrames=params.Results.padMissingFrames;
outputType=params.Results.outputType;


%should we run in parallel?
P=gcp('nocreate');
loadInParallel=false;
if ~supressParallelLoading && ~isempty(P)
    loadInParallel=true;
end



warning off
imageInfo=imfinfo(FileName);
warning on 

%Number of columns in structure is equal to the number of frames (but
%sometimes it seems to be a row vector);
numFrames=length(imageInfo);

if nargin<2 %Load all frames
    imSize=[imageInfo(1).Height,imageInfo(1).Width,numFrames];
    imageStack=zeros(imSize,outputType);

    if loadInParallel
        parfor frame=1:numFrames
            OriginalImage=cast(imread(FileName,frame),outputType);
            imageStack(:,:,frame)=OriginalImage;
        end 
    else
        for frame=1:numFrames
            OriginalImage=cast(imread(FileName,frame),outputType);
            imageStack(:,:,frame)=OriginalImage;
        end 
    end 

else %load sub-set of frames

    f=find(frames>numFrames | frames<1);
    frames(f)=[];
    if length(frames)<1
        error('No frames selected');
    end
    
    imSize=[imageInfo(1).Height,imageInfo(1).Width,length(frames)];
    imageStack=zeros(imSize,outputType);

    if loadInParallel
        parfor ii=1:length(frames)
            frame=frames(ii);
            OriginalImage=cast(imread(FileName,frame),outputType);
            imageStack(:,:,ii)=OriginalImage;
        end
    else
        for ii=1:length(frames)
            frame=frames(ii);
            OriginalImage=cast(imread(FileName,frame),outputType);
            imageStack(:,:,ii)=OriginalImage;
        end
    end

    %Pad out if the user asked for this
    if padMissingFrames && ~isempty(frames)
        out=zeros(imSize,outputType);
        out(:,:,frames) = imageStack;
        imageStack = out;
    end
    
end

