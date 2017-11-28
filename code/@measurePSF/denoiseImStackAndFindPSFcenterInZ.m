function denoiseImStackAndFindPSFcenterInZ(obj)
    % Estimate the slice that contains center of the PSF in Z by finding the brightest point.

    obj.PSFstack = double(obj.PSFstack);
    for ii = 1:size(obj.PSFstack,3)
        obj.PSFstack(:,:,ii) =  medfilt2(obj.PSFstack(:,:,ii),[obj.medFiltSize,obj.medFiltSize]);
    end
    obj.PSFstack = obj.PSFstack - median(obj.PSFstack(:)); %subtract the baseline because the Gaussian fit doesn't have an offset parameter

            %Further clean the image stack since we will use the max command to find the peak location
    DS = imresize(obj.PSFstack,0.25); 
    for ii = 1:size(DS,3)
        DS(:,:,ii) = conv2(DS(:,:,ii),ones(2),'same');
    end
    Z = max(squeeze(max(DS))); 

    z = max(squeeze(max(DS)));
    f = obj.fit_Intensity(z,1,1); 
    obj.psfCenterInZ = round(f.b1);

    if obj.psfCenterInZ > size(obj.PSFstack,3) || obj.psfCenterInZ<1
        fprintf('PSF center in Z estimated as slice %d. That is out of range. PSF stack has %d slices\n',...
            obj.psfCenterInZ,size(obj.PSFstack,3))
        fprintf('Setting centre to mid-point of stack\n')
        obj.psfCenterInZ=round(size(obj.PSFstack,3));
    end

    obj.maxZplane = obj.PSFstack(:,:,obj.psfCenterInZ);
            % We will use this plane to find the bead in X and Y by fitting gaussians along these dimensions.
            % We will use these values to show cross-sections of it along X and Y.
            % Always apply a moderate median filter to help ensure we get a reasonable fit
    if obj.medFiltSize==1
        obj.maxZplaneForFit = medfilt2(obj.maxZplane,[2,2]); %Filter this plane alone if no filtering was requested
    else
        obj.maxZplaneForFit = obj.maxZplane;
    end

end %Close denoiseImStackAndFindPSFcenterInZ
