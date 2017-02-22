function [psfCenterInX,psfCenterInY,badFit]=findPSF_centre(im)
    % Used by measurePSF to find the maximum of a 2D image 
    %
    %

    %Find the peak of the image
    f = measurePSF.fit_Intensity(max(im,[],1),1);
    psfCenterInX = round(f.b1);

    badFit=false;
    if psfCenterInX<0 || psfCenterInX>size(im,1)
        fprintf('PSF centre not found along X dimension. Are your data noisy?\n')
        psfCenterInX=1;
        badFit=true;
    end

    f = measurePSF.fit_Intensity(max(im,[],2),1);
    psfCenterInY = round(f.b1);
    if psfCenterInY<0 || psfCenterInY>size(im,2)
        fprintf('PSF centre not found along Y dimension. Are your data noisy?\n')
        psfCenterInY=1;
        badFit=true;
    end