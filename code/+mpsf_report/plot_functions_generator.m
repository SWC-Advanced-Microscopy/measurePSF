function out = plot_functions_generator(data_dir)
% Look in a directory containing maintenance data and generate a structure
% that can be used to produce the plots.
%
% function out = plot_functions_generator(data_dir)
%
% Purpose
% This function generates a structure that contains information about which
% data exist in the defined folder and which functions will plot these. The
% structure can then be passed to a downstream plotting functions to actually
% make the plots. This could be simply making and saving the plots as separate
% PDFs or using the MATLAB report generator to make a nicely formatted report.
%
%
%
% Inputs
% data_dir - optional, if nothing is provided the current directory is used
%
%
% Also see:
% mpsf_report.plotAllBasic
%
% Rob Campbell - SWC 2022


if nargin<1
    data_dir = pwd;
end


d = dir(data_dir);


n=1;
for ii=1:length(d)
    tmp = d(ii);

    if startsWith(tmp.name,'electrical')
        out(n) = generic_generator_template(tmp);
        out(n).plotting_func = @plot.electrical_noise;
        n=n+1;
    elseif startsWith(tmp.name,'uniform_slice_zoom_1')
        out(n) = generic_generator_template(tmp);
        out(n).plotting_func = @plot.uniform_slide;
        n=n+1;
        out(n) = generic_generator_template(tmp);
        out(n).plotting_func = @plot.uniform_slide_laser_stability;
        n=n+1;
    elseif startsWith(tmp.name,'lens_paper_')
        out(n) = generic_generator_template(tmp);
        out(n).plotting_func = @plot.lens_paper;
        n=n+1;
    end
end


if ~exist('out','var')
    fprintf('No data found in directory %s\n', data_dir)
    out = [];
end


% Internal functions follow
function out = generic_generator_template(t_dir)
    out.full_path_to_data = fullfile(t_dir.folder,t_dir.name);
    out.plotting_func = [];
    out.laser_wavelength = mpsf_report.laser_wavelength_from_fname(t_dir.name);
    out.laser_power = mpsf_report.laser_power_from_fname(t_dir.name);
