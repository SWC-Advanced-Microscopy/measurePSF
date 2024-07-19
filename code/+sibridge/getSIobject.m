function hSI = getSIobject
% Looks in the base workspace for the ScanImage object and returns it
%
% function hSI = sibridge.getSIobject
%
% Purpose
% Returns a copy of the ScanImage API object in the MATLAB base workspace.
% This is used by other functions in this module to access attributes of
% of ScanImage. Returns empty if no ScanImage can be found.
%
% Inputs
% None
%
% Outputs
% hSI - A copy of the ScanImage object. If ScanImage is not started or
%       otherwise not present, then hSI will be empty.
%
%
% Rob Campbell - Jan 2020



scanimageObjectName='hSI';
W = evalin('base','whos');
SIexists = ismember(scanimageObjectName,{W.name});

hSI=[];

if ~SIexists
    fprintf('\nScanImage not started, unable to link to it.\n\n')
    return
end

API = evalin('base',scanimageObjectName); % get hSI from the base workspace
if ~isa(API,'scanimage.SI')
    fprintf('hSI is not a ScanImage object.\n')
    return
end


hSI=API;
