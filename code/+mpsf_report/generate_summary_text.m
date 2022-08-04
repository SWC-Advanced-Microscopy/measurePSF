function out = generate_summary_text(data_dir)
% Generate a text summary of data in this folder.
%
% function out = generate_summary_text(data_dir)
%
% Purpose
% This function generates a text summary of the information present in this folder.
% This can be embedded into a report.
%
% Inputs
% data_dir - optional, if nothing is provided the current directory is used
%
%
% Rob Campbell - SWC 2022



if nargin<1
    data_dir = pwd;
end





% Load an image extract from it information about the microscope.
d = mpsf_report.getScanImageTifNames(data_dir);

header = sibridge.readTifHeader(fullfile(d(1).folder,d(1).name));

scanimageVersion = sprintf('%d.%d.%d', header.VERSION_MAJOR, ...
                                       header.VERSION_MINOR, ...
                                       header.VERSION_UPDATE);



% Obtain the date range over which the data were recorded
dates = {d.date};
dates = cellfun(@(tdate) regexprep(tdate,' .*',''), dates, 'UniformOutput',false);
% Sort dates
[~,ind]=sort(datenum(dates));
dates = unique(dates(ind));

% Make a string that describes when data were acquired
if length(dates)==1
    acqDate = sprintf('on %s', dates{1});
else
    acqDate = sprintf('between %s and %s', dates{1}, dates{end});
end



%%
% Make summary text
out = [...
    sprintf('Microscope summary data were acquired %s ', acqDate), ...
    sprintf('using ScanImage version %s.\n', scanimageVersion)];
