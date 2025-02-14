function figHandle = returnFigureHandleForFile(fname)
    % Find a figure associated with this file name or make one and tag it
    %
    % fig = mpqc.tools.returnFigureHandleForFile(fname)
    %
    % Purpose
    % If a figure has already been made with data from this file name, we do
    % not make another but reuse it. Otherwise make a new figure
    %
    % Inputs
    % fname = string file name
    %
    % Outputs
    % figHandle - handle to the figure we will use for plotting
    %
    %
    % Rob Campbell, SWC AMF


    tag = findobj('Tag',fname);

    if isempty(tag)
        figHandle = figure;
        figHandle.Tag = fname;
    else
        figHandle = figure(tag);
    end

    clf
