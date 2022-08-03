function plotAllBasic(genPlotStructure)
    % Makes all plots defined by the gen plot structure
    %
    % function plotAllBasic(genPlotStructure)
    %
    % Purpose
    % Simply runs through all the elements of the structure produced by
    % mpsf_report.plot_functions_generator and creates all the plots.
    % It then leaves the plot windows open. If no input is provided,
    % it looks in the current directory for data.
    %
    % Inputs
    % genPlotStructure - [optional] output of mpsf_report.plot_functions_generator
    %
    % Outputs
    % none
    %
    % Rob Campbell - SWC 2022


    if nargin<1
        genPlotStructure = mpsf_report.plot_functions_generator;
    end

    fig=[];
    for ii=1:length(genPlotStructure)
        t_dat = genPlotStructure(ii);

        t_dat.plotting_func(t_dat.full_path_to_data)
        fig(end+1) = gcf;
    end

    mpsf_tools.TileFigures(fig);

