function laser_power = laser_power_from_fname(fname)
% Get laser power from filename
%
%    function laser_power = laser_power_from_fname(fname)
%
% Purpose
% Return laser power in mW from a file name produced by the record functions
%
% Rob Campbell, SWC AMF


tok = regexp(fname,'.*_(\d+)mW_.*','tokens');

if isempty(tok)
    laser_power = '';
else
    laser_power = str2num(tok{1}{1});
end
