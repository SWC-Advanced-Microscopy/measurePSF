function tPath=logpath
	% Return path to which log information will be saved
	%
	% function desktop_dir = mpsf.tools.logpath
	%
	% Purpose
	% This function is used by measurePSF and Grid2MicsPerPixel to choose
	% the location to save PDF files, etc. By default we will save to the Windows
	% Desktop, Mac Desktop, or Linux home folder. However, if the user is currently
	% in a directory that contains the PSF recording files then we will save in
	% the current directory instead.
	%
	% Inputs
	% none
	%
	% Outputs
	% tPath - path to which to save
	%
	%
	% Rob Campbell - SWC 2022


	% Are there PSF files produced by record.PSF in this folder?
	% TODO -- what about also saving here if there are other image types (grid)?
	if ~isempty(dir('PSF_*nm*mW_2*.tif'))
		tPath = pwd;
		return
	end

 	
 	if ispc
 		% On Windows return the path to the User's Desktop
	 	[~,userPath] = system('echo %USERPROFILE%');
 		userPath = strtrim(userPath);
	 	tPath = fullfile(userPath,'Desktop');
	 elseif ismac
	 	% Macs
	 	tPath = '~/Desktop';
	 elseif isunix
	 	% Because we've already done Macs this is Linux
	 	tPath = '~'; % In case there is no desktop folder in this distro
	 end

