function findPSF_centreInXY(obj,im)
    % Used by measurePSF to find the maximum of a 2D image
    %
    %
    % Rob Campbell, Basel Biozentrum, 2016

    %Find the peak of the image
    f = obj.fit_Intensity(max(im,[],1),1);

    if isempty(f)
        obj.psfCenterInX=[];
        obj.psfCenterInY=[];
        return
    end

    obj.psfCenterInX = round(f.b1);

    obj.badFit=false;

    if obj.psfCenterInX<0 || obj.psfCenterInX>size(im,1)
        fprintf('PSF centre not found along X dimension. Are your data noisy?\n')
        obj.psfCenterInX=1;
        obj.badFit=true;
    end

    f = obj.fit_Intensity( max(im,[],2), 1);
    obj.psfCenterInY = round(f.b1);
    if obj.psfCenterInY<0 || obj.psfCenterInY>size(im,2)
        fprintf('PSF centre not found along Y dimension. Are your data noisy?\n')
        obj.psfCenterInY=1;
        obj.badFit=true;
    end
end
