function add_scale_axis_tick_labels(ax,micsPixXY)
    % Change y and x axis labels so they are in microns
    %
    % mpqc.tools.add_scale_axis_tick_labels(ax,micsPixXY)
    %
    % Purpose
    % For a 2D image, we add 5 tick marks labeled in microns based on micsPixXY.
    %
    %
    % Inputs
    % ax - axes to target
    % micsPixXY - microns per pixel in x/y
    %
    %
    % Rob Campbell, SWC AMF, initial commit 2022


    nTicks = 5;

    xTick = linspace(1, floor(ax.XLim(2))-1, nTicks);
    yTick = linspace(1, floor(ax.YLim(2))-1, nTicks);



    xTickLabel = (xTick * micsPixXY);
    yTickLabel = (yTick * micsPixXY);

    % Centre around zero
    xTickLabel = round(xTickLabel - mean(xTickLabel));
    yTickLabel = round(yTickLabel - mean(yTickLabel));


    ax.XTick = xTick;
    ax.YTick = yTick;


    ax.XTickLabel = xTickLabel;
    ax.YTickLabel = yTickLabel;


    xlabel('x axis [\mum]')
    ylabel('y axis [\mum]')
