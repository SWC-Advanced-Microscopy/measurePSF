# measurePSF

This repository contains the following MATLAB tools that are designed to work with ScanImage.

* `recordPSF` to acquire PSF stacks
* `measurePSF` to estimate PSF size. For a demo, run `measurePSF('demo')`. 
* `Grid2MicsPerPixel`  measures the number of microns per pixel along x and y by analyzing an image of an EM grid. 
* `mpsf_tools.meanFrame` plots the mean frame intensity as a function of time whilst you are scanning.


![cover image](https://raw.githubusercontent.com/raacampbell/measurePSF/gh-pages/realBead.png "Main Window")


## Installation
Add the measurePSF `code` directory to your MATLAB path. 





## Obtaining a PSF in ScanImage with averaging and fastZ
To get a good image of sub-micron bead I generally zoom to about 20x or 25x and use an image size of 256 by 256 pixels. 
I take z-plane every 0.25 microns and average about 25 to 40 images per per plane. 
It's not worth doing more because we'll be fitting a curve to z-intensity profile.
To measure the PSF you can either use the included `recordPSF` function or manually set up ScanImage (see `documentation` folder if you need to do that). 

## Using `recordPSF` to obtain a PSF
* Find a bead, zoom in. 
* Select only one channel to save in the CHANNELS window.
* Set the averaging to the quantity you wish to use.
* Move the focus *down* to the lowest point you wish to image and press press "Zero Z" in MOTOR CONTROLS
* Now focus back up to where you want to start the stack and press "Read Pos" in MOTOR CONTROLS. 
This is the number of microns you will acquire (ignore the negative sign if present). 
* Run `recordPSF` with number of microns obtained above as the first input argument. This will obtain the stack with a 0.25 micron resolution using the averaging you have set. e.g. `recordPSF(12)` for a 12 micron stack. The save loction is reported to screen. You can define a different z resolution using the second input argument. 


## Measuring the PSF
To view the PSF run `measurePSF` and load the saved stack using the GUI. For more info type `help measurePSF`.
If loading ScanImage TIFFs the voxel size is extracted automatically from the header information in the file.
Otherwise, this information can be provided using the second and third input arguments (see `help measurePSF`). 



## Measuring FOV size with an EM grid
See documentation folder for how to make an EM grid slide.

To image the slide:
* Copper will autofluoresce when illuminated by a 2-photon laser. 
* Use any 2p wavelength and very low power e.g. 3 mW. 
* The grid should be oriented so that it's aligned relatively closely with the scan axes (i.e. the edges of the image). 
This will make it easier to see distortions by eye and also to run `Grid2MicsPerPixel`.
* Hit "Focus" in ScanImage. Acquire data with just one channel. Get a good clear grid image and average a few frames if needed. 
* Press "Abort" to stop scanning once a good image is obtained.
* Run `Grid2MicsPerPixel` to measure the FOV. The function will automatically pull data from ScanImage. 
Look at the diagnostic figures to ensure function has found most of the grid lines (it uses the median grid line distance so you don't need all the lines). If very few grid lines are detected, the results will be meaningless. 
* You can use the buttons in the GUI to obtain new images. 
* Once you are happy with the results you can use the "Apply FOV" button to calibrate ScanImage. 


## Plotting mean frame intensity
Run `mpsf_tools.meanFrame` to bring up a figure window that plots mean frame intensity during scanning. 
This function is used for things like tweaking a pre-chirper. 
See `help mpsf_tools.meanFrame` for advanced usage. 


### Requirements
The function has been well well-tested under R2016b and later. 
It should also work on R2016a. It's known to fail on 2015b and earlier.
Requires the Curve-Fitting Toolbox, the Image Processing Toolbox, and the Stats Toolbox.




# Change-Log
* 2020/01/30 -- Add "mpsf_tools.meanFrame" for displaying a rolling frame average (v7.5)
* 2020/01/14 -- Add button that allows the current image to be saved to the desktop (v6.25)
* 2020/01/14 -- Add edit boxes and checkboxes to allow the user to modify on the fly what would otherwise have been input arguments. (v5.75)
* 2020/01/14 -- Get voxel size from ScanImage TIFF header. (v4.75)
* 2020/01/14 -- If no input args to measurePSF, bring up the load GUI. (v4.25) [+0.75]
* 2020/01/13 -- Convert Grid2MicsPerPixel to a class and add buttons to interact with SI (v3.45)
* 2020/01/08 -- Grid2MicsPerPixel optionally can extract the grid image directly from ScanImage (v1.45)
* 2018/11/09 -- Add `recordPSF` (v1.0)
* 2017/11/28 -- Simple GUI for interactive cropping of a desired bead.
* 2017/11/28 -- Improve output data and don't display FWHM for directions in which the user defined no microns per pixel.
* 2017/11/27 -- Convert `measurePSF` to a class so adding new features is easier.

