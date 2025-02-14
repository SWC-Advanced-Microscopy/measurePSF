function plotAllBasic(data_dir)
    % Makes all plots defined by the gen plot structure
    %
    % function plotAllBasic(data_dir)
    %
    % Purpose
    % Makes all available plots from a data directory and tiles them over the screen.
    % If no input is provided, it looks in the current directory for data.
    %
    % Inputs
    % data_dir - [optional] location of data directory.
    %
    % Outputs
    % none
    %
    % Rob Campbell, SWC AMF, initial commit 2022



    if nargin<1
        data_dir = pwd;
    end

    genPlotStructure = mpqc.report.plot_functions_generator(data_dir);


    fig=[];
    for ii=1:length(genPlotStructure)
        t_dat = genPlotStructure(ii);

        [~,fname,ext]=fileparts(t_dat.full_path_to_data);

        fprintf('%d/%d. Processing %s%s\n', ii, length(genPlotStructure), fname, ext)

        t_dat.plotting_func(t_dat.full_path_to_data)
        fig(end+1) = gcf;
    end

    fprintf('Made %d figures\n', length(fig))

    mpqc.tools.TileFigures(fig);

