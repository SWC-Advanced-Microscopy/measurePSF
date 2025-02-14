function varargout = standard_light_source(dirToSearch)
    % Make plots of data from the standard light source
    %
    % mpqc.plot.standard_light_source(dirToSearch)
    %
    % Purpose
    % Showing PMT response as a function of gain using the standard light source
    %
    % Inputs
    % dirToSearch - Directory in which to search for standard light source data.
    %              Searches the current directory if is empty or missing.
    %
    % Outputs
    % pltData - The data that underlies the plot
    %
    %
    % Rob Campbell, SWC AMF, initial commit Q4 2024


    if nargin<1 || isempty(dirToSearch)
        dirToSearch = pwd;
    end

    files = dir(fullfile(dirToSearch,'*_standard_light_source_*.tif'));

    if isempty(files)
        fprintf('Found no standard light source data to plot\n')
        return
    end

    % get the number PMT channels by looking at the first file in the list
    m = imfinfo(fullfile(dirToSearch,files(1).name)); % length == num chans

    PMT_gain = zeros(1,length(files));
    mean_value = zeros(length(files),length(m));

    fprintf('Loading data')
    for jj = 1:length(files)
        fname = fullfile(dirToSearch,files(jj).name);
        [imstack,metadata] = mpqc.tools.scanImage_stackLoad(fname,false);

        % Fail gracefully if the file could not be loaded
        if isempty(imstack)
            continue
        end
        fprintf('.')
        % Log gain and mean pixel values
        PMT_gain(jj) = metadata.gains(1);
        mean_value(jj,:) = squeeze(mean(imstack,[1,2]));
    end
    fprintf('\n')

    % Quit if nothing was loaded
    if all(mean_value==0)
        return
    end

    % Plot!
    % Make a new figure or return a plot handle as appropriate
    fig = mpqc.tools.returnFigureHandleForFile([dirToSearch,mfilename]);
    offset_subtracted = mean_value-mean_value(1,:);

    p=plot(offset_subtracted,'o-','MarkerSize',5);

    % Because ...'MarkerFaceColor','auto'... didn't do what was expected.
    for ii=1:length(p)
        p(ii).MarkerFaceColor = p(ii).Color;
    end

    legend(metadata.channelName(metadata.channelSave),'Location','NorthWest')

    set(gca,'XTickLabels',PMT_gain)
    xlabel('Gain')
    ylabel('Signal (AU relative to zero gain)')
    grid on


    if nargout>0
        pltData.PMT_gain = PMT_gain;
        pltData.mean_value = offset_subtracted;
        varargout{1} = pltData;
    end
