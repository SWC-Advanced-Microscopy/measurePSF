function plotPhotonFit(STATS)
% Diagnostic plots for the compute_sensitivity function.
%
% function mpqc.tools.plotPhotonFit(STATS)
%
% Purpose
% The function "compute_sensitivity" takes as input a series of image frames from a
% scanning microscope and returns an array of statistics as output. The key statistic
% is "quantal_size", which defines the number or raw data units per photon. The quantal
% size is the slope of variance as a function of mean over pixels. If the fit is poor, or
% the data have an unusual distribution, then the estimate of the slope can be compromised.
% This function allows the user to check visually if the fit is of reasonable quality.
%
% Inputs (Required)
% STATS - The output of compute_sensitivity
%
%
% Example
% OUT = mpqc.tools_get_quantal_size_from_file(fname);
% mpqc.tools.plotPhotonFit(OUT)
%
%
%
% Rob Campbell, SWC AMF, initial commit February 2025
%
%
% Acknowledgements
% This function is based on this work:
% https://github.com/datajoint/anscombe-numcodecs by Dimitri Yatsenko


figure(12349)
clf
% Plot the variance as a function of the mean and overlay the fit line
intensity = STATS.min_intensity:STATS.max_intensity - 1;
plot(intensity,STATS.variance,'.', 'color',[0.35,0.35,1])

hold on
y = STATS.model(1) + intensity*STATS.model(2);
plot(intensity,y,'-r','LineWidth',2)
hold off

xlabel('Intensity')
ylabel('Variance')
grid on
axis tight
% Add some key statistics to the plot title
title(sprintf('Quantal size: %0.1f. Mean photons per pixel: %0.2f', ...
    STATS.quantal_size, STATS.photons_per_pixel))


% Make an inset plot showing the distribution
pos = get(gca,'Position');
origWidth=pos(3);
origHeight=pos(4);
topEdge=pos(2)+origHeight;
pos(3:4) = pos(3:4)*0.3';
pos(2) = topEdge - pos(4) - origHeight*0.05;
pos(1) = pos(1) + origWidth*0.05;

axes('position',pos)

tColor = [0.85,0.65,0.65];
area(intensity,log(STATS.counts),'EdgeColor', tColor, 'FaceColor', tColor)
xlabel('Intensity')
ylabel('log(Counts)')
grid on
set(gca,'YAxisLocation','Right')
axis tight
