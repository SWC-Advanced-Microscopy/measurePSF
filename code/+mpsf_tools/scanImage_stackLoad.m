function imStack=scanImage_stackLoad(filePattern)
% load slow z-stack from ScanImage for PSF analysis
%
%
% function imStack=scanImage_stackLoad(filePattern)
%
% If ScanImage stored z-stacks as separate files for each layer
% then use this function to load these and convert to one stack. 
% **Assumes one channel was collected**
% It's generally easier to set up the z-stack properly by 
% checking the enable button on the z-stack GUI. Then you get
% the whole stack in one file. 
%
% Inputs
% filePattern - string defining the file pattern to search for
%
% 
% Example
% imS = scanImageStackLoad('Bead_*.tif')
%
% 
% Hint:
% Tell ScanImage to start numbering the files from 10 to avoid
% ordering issues with slices 1 through 9
%
%
% Rob Campbell - Basel 2016

d=dir(filePattern);

imStack = mean(load3Dtiff(d(1).name),3);
imStack = repmat(imStack,[1,1,length(d)]);

for ii=2:length(d)
	imStack(:,:,ii) = mean(load3Dtiff(d(ii).name),3);
end

