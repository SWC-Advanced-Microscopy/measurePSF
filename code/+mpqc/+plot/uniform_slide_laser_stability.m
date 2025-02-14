function varargout = uniform_slide_laser_stability(fname)
    % Plots that explore how stable are the the fluoro slide images with time
    %
    % function legend_text = mpqc.plot.uniform_slide_laser_stability(fname)
    %
    % Optionally returns text that describes the plots
    %
    % Rob Campbell, SWC AMF

    [imstack,metadata] = mpqc.tools.scanImage_stackLoad(fname);
    if isempty(imstack)
        return
    end

    micsPerPixelXY = metadata.micsPerPixelXY;

    % Make a new figure or return a plot handle as appropriate
    fig = mpqc.tools.returnFigureHandleForFile([fname,mfilename]);

    clf
    subplot(2,2,1)
    t = imstack;
    t = permute(t,[1,3,2]);
    mu = mean(t,3);
    imagesc(mu)

    xlabel('Frame #')
    ylabel('Image row mean')

    ax = subplot(2,2,3);
    average_sequential_diff = mean(abs(diff(mu,[],2)),2);
    Pr = (average_sequential_diff./mean(mu,2))*100;
    plot(Pr)
    hold on
    plot([1,size(mu,1)],[mean(Pr),mean(Pr)],'--r')
    hold off

    xlim([1,size(mu,1)])
    xlabel('Image row')
    ylabel('Mean % change')



    subplot(2,2,2)
    t = imstack;
    t = permute(t,[2,3,1]);
    mu = mean(t,3);
    imagesc(mu)

    xlabel('Frame #')
    ylabel('Image column mean')


    ax(2) = subplot(2,2,4);
    average_sequential_diff = mean(abs(diff(mu,[],2)),2);
    Pc = (average_sequential_diff./mean(mu,2))*100;
    plot(Pc)
    hold on
    plot([1,size(mu,1)],[mean(Pc),mean(Pc)],'--r')
    hold off

    xlim([1,size(mu,1)])
    ylabel('Mean % change')
    xlabel('Image column')


    % Make both Y axes of the lower plots the same
    YM = max([ax.YLim]);

    % if the maximum percentage change is less than 5% then we set it to 5%. Otherwise
    % we go with whatever is the actual value. This hopefully makes it easier to compare across
    % sessions or rigs.
    if YM < 5
        YM = 5;
    end

    ax(1).YLim = [0,YM];
    ax(2).YLim = [0,YM];


    if nargout>0
        txt = [ ...
        'Figures describing rapid changes of image intensity over time. ', ...
        sprintf('Image size of %d by %d pixels over %d frames at %0.1f FPS.', ...
                size(imstack), round(metadata.scanFrameRate)), ...
        sprintf('The left two plots summarise how each image row changes in intensity over the %d frames.', ...
            size(imstack,3)), ...
        sprintf('The right two plots summarise how each image column changes in intensity over the %d frames.', ...
            size(imstack,3)), ...
        'The top left plot shows the mean of each image row over frames. ', ...
        'The top right plot shows the mean of each image column over frames. ', ...
        sprintf('Each line is acquired in %0.1f us, ', metadata.linePeriod*1E6), ...
        ' and rapid changes in laser power should be more obvious if we look at the mean of each ', ...
        'line over frames compared to the mean of each column.', ...
        sprintf('\n\n'), ...
        'The lower pair of plots summarize how much the intensity of each row or line changes from one frame to the next. ', ...
        'Each plot shows the average absolute intensity changes of adjacent frames in image rows (left) and image rows (right). ', ...
        'Data are shown as a percentage change with respect to image mean. ', ...
        sprintf('In this case image rows vary over frames by about %0.1f%% and image columns by %0.1f%%. ', ...
            mean(Pr),mean(Pc))
        ];

        if mean(Pr) > mean(Pc)
            txt = sprintf(['%sConsistent with there being fast fluctuations in signal, there is %0.1f times more '...
                        'variation across the same row over time than the same column.'], txt, ...
                        mean(Pr)/mean(Pc));
        else
            txt = sprintf('%sThese data do not show more variation across rows than across columns. ', txt);
            if mean(Pc)<1.2
                txt = [txt,'The variation over columns is low so probably this means the signal is very stable.'];
            elseif mean(Pc)>1.2 && mean(Pc)<2
                txt = [txt,'The variation over columns is somewhat low so probably the signal is stable, but you might want to explore further.'];
            elseif mean(Pc)>2
                txt = [txt,'The variation over columns is somewhat high so maybe the signal is not very stable, but you should explore further.'];
            end
        end
        varargout{1} = txt;
    end
