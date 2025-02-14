function bestAng=findGridAngle(obj,im)
    % Iteratively find the grid orientation that makes the grid lines
    % parallel with the axes.
    % Algorithm:
    % START
    % Projecting the image onto two 1D vectors (rows and columns).
    % Calculating the total variance (see getVar) along both dimensions.
    % Repeat for a range of grid angles in an adaptive manner to improve speed.
    % The variance is maximimal when the grid is parallel with the axes.
    % END
    %
    %
    % Rob Campbell, Basel Biozentrum, 2016

    startAngleRange=25;
    startRes=5;
    minRes=0.05;

    currentRes = startRes;
    currentAngle=startAngleRange;
    bestAng = 0 ;
    T=1;

    if  obj.verbose
        fprintf('Finding angle of grating: ')
        optFig=figure
    end

    while currentRes>=minRes

      angs = -currentAngle : currentRes : currentAngle;
      angs = angs + bestAng;
      thisV = zeros(size(angs));
      n=1;
      for a=angs
        thisV(n) = getVar(im,a, obj.verbose);
        n=n+1;
        T=T+1;
      end

      %update variables
      [~,ind]=max(thisV);
      bestAng = angs(ind);

      if  obj.verbose
        fprintf(' -> %0.1f (%0.2f)', bestAng, currentRes)
      end

      currentRes = currentRes * 0.6 ;
      currentAngle = currentAngle * 0.4;
    end

    if obj.verbose
        close(optFig)
        fprintf('\n')
    end


    fprintf('Angle %0.3f in %d iterations\n', bestAng, T)
end %close findGridAngle


function v=getVar(im,ang,verbose)
    %rotate grid by angle "ang", project to x and y. calculate total variance along these axes
    %
    % Rotate image "im" by angle "var", project the image onto the rows and columns, calculate the variance of each and sum them

    if nargin<2
        verbose=false;
    end

    tmp=imrotate(im,ang,'crop');

    if verbose

      subplot(1,2,1)
      imagesc(tmp)
    end

    tmp(tmp==0)=nan;

    m1 = nanmean(tmp,1);
    m2 = nanmean(tmp,2);

    if verbose
      subplot(1,2,2)
      cla
      plot(m1,'-r')
      hold on
      plot(m2,'-k')
      axis tight
      xlim([1,length(m1)])
      drawnow
    end
    v = var(m1) + var(m2);
end %close getVar
