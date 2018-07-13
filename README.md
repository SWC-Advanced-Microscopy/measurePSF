# measurePSF

MATLAB routine to measure a microscope point-spread function (PSF) based upon an image-stack of a sub-micron bead. 
To run, add measurePSF to your path or `cd` to the directory containing the file. To run a demo, just run the command `measurePSF`. You should then get a figure window much like the one below. Read the help text. 

The repository also contains `Grid2MicsPerPixel`, which can be used to measure the number of microns per pixel along x and y by analyzing an image of an EM grid. 

### Obtaining a PSF in ScanImage with averaging and fastZ
To get a good image of sub-micron bead I generally zoom to about 20 or 25x and an image size of 1024 by 1024. 
I take z-plane every 0.25 microns and average about 40 images per per plane. 
It's not obvious how to do the averaging.
This is the protocol for doing a slow z-stack with the fast-z device.

* Using the slow-z device and reading its position, determine the depth at which you wish to start imaging and note how far below it you wish to go. 
* Place objective at the top of the stack you wish to acquire with the slow-z motor.
* Un-check the `Enable` box for the fast-z under `FAST Z CONTROLS`.
* In the same window set `# Slices` and `Step/Slice` (microns per step) to cover the range of depths you need. 
  Sampling every 0.25 microns is nice for a 2-photon z-stack. 
* In the same window set the `Scan Type` to `Step`.
* Check `Sec Z` in `MOTOR CONTROLS`.
* Set the `Frame Rolling Average Factor` in `IMAGE CONTROLS` to the number of frames you wish to average. 
  40 frames is probably good enough.
* Check `Save` in `MAIN CONTROLS` and set `# Avg` to the same number of frames (e.g. 40).
* Set the right-hand box in the `Frames Done` line in `MAIN CONTROLS` to the number of images you are averaging.
* Press `GRAB` in `MAIN CONTROLS` to acquire a stack
* If the shutter opening and closing is annoying then set `hSI.hStackManager.shutterCloseMinZStepSize` to a value larger than you step size. 

### Measuring FOV size with an EM grid
You can use a copper EM grid of known pitch to measure the FOV your microscope. 
We use part number 2145C from [2spi.com](http://www.2spi.com/category/grids)
These grids have a pitch of 25 microns with 19 micron holes. 
To set up the grid on a slide:

* Use a dissection scope and forceps to position the grid on a glass slide such that the grid lines are square with the edges of the slide. 
This will make positioning the grid under the microscope a lot easier. 
* Place a coverslip over the grid and seal with nail varnish. 

To image the slide:
* Copper will autofluoresce when illuminated by a 2-photon laser. 
* Use any 2p wavelength and very low power e.g. 3 mW. 
* The grid should be oriented so that it's aligned relatively closely with the scan axes (i.e. the edges of the image). 
This will make it easier to see distortions by eye and also to run `Grid2MicsPerPixel`.
* Make sure the grid is in focus. Average images if needed. Feed the image into `Grid2MicsPerPixel` to measure the FOV.

### Requirements
The function has been well well-tested under R2016b and later. 
It should also work on R2016a. It's known to fail on 2015b and earlier.
Requires the Curve-Fitting Toolbox and the Image Processing Toolbox.


![cover image](https://raw.githubusercontent.com/raacampbell/measurePSF/gh-pages/realBead.png "Main Window")


# Change-Log
* 28th Nov 2017 -- Simple GUI for interactive cropping of a desired bead.
* 28th Nov 2017 -- Improve output data and don't display FWHM for directions in which the user defined no microns per pixel.
* 27th Nov 2017 -- Convert `measurePSF` to a class so adding new features is easier.
