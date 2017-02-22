function out = round(in,sigFig)
	% round a number to a given number of decimal places
	%
	% function out = round(in,sigFig)
	%
	% Purpose
    % Needed for earlier MATLAB releases where round doesn't have a
    % a second input argument to specify the number of decimal places.
    %
    %
    
    if nargin<2
        sigFig=1;
    end
    out = round(in * 10*sigFig)/(10*sigFig);

