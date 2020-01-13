function setObjectiveResolution(imSizeInMicrons)
% Set the FOV in ScanImage from a measured FOV
%
% function hSI = sibridge.setObjectiveResolution
%
% Purpose
% Sets the scanimage "objectiveResolution" property so that 
% ScanImage reports the FOV specifed by imSizeInMicrons. This
% is automatically saved by ScanImage for future use, so you
% do not have to do anything further. 
%
%
% Inputs
% imSizeInMicrons
%
%
% Outputs none
%
% Rob Campbell - Jan 2020


im=[];

hSI = sibridge.getSIobject;
if isempty(hSI)
    return
end



imFOV = hSI.hRoiManager.imagingFovUm;
imFOV = round(range(imFOV(:,1)),3);

hSI.objectiveResolution = hSI.objectiveResolution / (imFOV/imSizeInMicrons);

%Confirm this worked and report objective resolution
imFOV = hSI.hRoiManager.imagingFovUm;
imFOV = round(range(imFOV(:,1)),3);

if imFOV ~= imSizeInMicrons
    fprintf('Failed to set FOV in ScanImage. Desired FOV is %0.2f but actual is %0.2f\n', ...
        imSizeInMicrons, imFOV)
else
    fprintf('Set ScanImage FOV to %0.2f microns using an objective resolution of %0.5f\n', ...
        imSizeInMicrons, hSI.objectiveResolution)    
end
