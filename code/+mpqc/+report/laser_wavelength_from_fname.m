function laser_wavelength = laser_wavelength_from_fname(fname)
% Get laser wavelength from filename
%
%    function laser_wavelength = laser_wavelength_from_fname(fname)
%
% Purpose
% Return laser wavelength in mW from a file name produced by the record functions
%
% Rob Campbell, SWC AMF


tok = regexp(fname,'.*_(\d+)nm_.*','tokens');

if isempty(tok)
    laser_wavelength='';
else
    laser_wavelength = str2num(tok{1}{1});
end
