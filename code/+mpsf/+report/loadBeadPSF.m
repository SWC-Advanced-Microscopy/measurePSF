function varargout = loadBeadPSF(fname)
% Load bead PSF figure file
%
%  function stats = loadBeadPSF(fname)
%
% Purpose
% Load bead PSF figure file so it can be incorporated into reports.
% Optionally return structure containing stats about the bead.
%
% Inputs
% fname - relative or full path to file to load.
%
% Outputs [optional]
% stats - PSF stats
%
%
% Rob Campbell, SWC AMF, initial commit 2022


warning off

fig = open(fname);

warning on


if nargout>0
    varargout{1} = fig.UserData;
end
