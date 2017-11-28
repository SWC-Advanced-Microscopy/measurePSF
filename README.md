# measurePSF

MATLAB routine to measure a microscope point-spread function (PSF) based upon an image-stack of a sub-micron bead. 
To run, add measurePSF to your path or `cd` to the directory containing the file. To run a demo, just run the command `measurePSF`. You should then get a figure window much like the one below. Read the help text. 

The repository also contains `Grid2MicsPerPixel`, which can be used to measure the number of microns per pixel along x and y by analyzing an image of an EM grid. 

### Requirements
The function has been well well-tested under R2016b and later. 
It should also work on R2016a. It's known to fail on 2015b and earlier.
Requires the Curve-Fitting Toolbox and the Image Processing Toolbox.


![cover image](https://raw.githubusercontent.com/raacampbell/measurePSF/gh-pages/realBead.png "Main Window")


# Change-Log
* 28th Nov 2017 -- Improve output data and don't display FWHM for directions in which the user defined no microns per pixel.
* 27th Nov 2017 -- Convert `measurePSF` to a class so adding new features is easier.