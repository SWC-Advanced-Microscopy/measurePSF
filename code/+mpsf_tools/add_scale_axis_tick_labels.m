function add_scale_axis_tick_labels(ax,micsPixXY)
    % Change y and x axis labels so they are in microns
    %
    % mpsf_tools.add_scale_axis_tick_labels(ax,micsPixXY)
    %
    % Purpose
    % For a 2D image, we add 5 tick marks labeled in microns based on micsPixXY.
    %
    %
    % Inputs
    % ax - axes to target
    % micsPixXY - microns per pixel in x/y
    % 
    % Rob Campbell - SWC 2022


    nTicks = 5;

    xTick = linspace(0, floor(ax.XLim(2))-1, nTicks);
    yTick = linspace(0, floor(ax.YLim(2))-1, nTicks);


    xTickLabel = round(xTick * micsPixXY);
    yTickLabel = round(yTick * micsPixXY);


    ax.XTick = xTick;
    ax.YTick = yTick;


    ax.XTickLabel = xTickLabel;
    ax.YTickLabel = yTickLabel;


    xlabel('x axis [\mum]')
    ylabel('y axis [\mum]')
