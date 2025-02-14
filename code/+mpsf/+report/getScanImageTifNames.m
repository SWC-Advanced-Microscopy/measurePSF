function fnames = getScanImageTifNames(data_dir)
% Find all the tiff files in diretcory that were made by ScanImage
%
% function fnames = getScanImageTifNames(data_dir)
%
% Purpose
% This function generates a dir structure containing ScanImage Tiff Files only.
%
% Inputs
% data_dir - optional, if nothing is provided the current directory is used
%
%
% Rob Campbell, SWC AMF, initial 2022



if nargin<1
    data_dir = pwd;
end


d = dir(fullfile(data_dir,'*.tif'));



for ii = length(d):-1:1

    h = imfinfo(fullfile(d(ii).folder,d(ii).name));

    if ~contains(lower(h(1).Software),'scanimage')
        d(ii) = [];
    end

end


fnames = d;
