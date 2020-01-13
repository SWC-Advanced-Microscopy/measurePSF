function varargout=getFOV
% Get the current FOV from ScanImage
%
% function imFOV = sibridge.getFOV
%
% Purpose
% Returns the current FOV from ScanImage. This is the FOV along one side
% and assumes a square pixel size. Note that, of course, the diagonal FOV
% is larger. 
%
% Inputs
% None
%
% Outputs (optional)
% imFOV - FOV along a side. If no outputs requested the FOV is 
%          printed to screen instea. 
%
%
% Rob Campbell - Jan 2020


im=[];

hSI = sibridge.getSIobject;
if isempty(hSI)
    return
end

imFOV = hSI.hRoiManager.imagingFovUm;
imFOV = round(range(imFOV(:,1)),3);
  
if nargout>0
    varargout{1}=imFOV;
else
    fprintf('ScanImage FOV is %0.2f microns.\n',imFOV)
end
