function PMT_gain = PMT_gain_from_fname(fname)
% Get PMT gain from filename
%
% function PMT_gain = PMT_gain_from_fname(fname)
%
% Purpose
% Return PMT gain in V from a file name produced by the record functions.
%
% Rob Campbell, SWC AMF, initial commit February 2025


tok = regexp(fname,'.*_(\d+)V_.*','tokens');

if isempty(tok)
    PMT_gain = '';
else
    PMT_gain = str2num(tok{1}{1});
end
