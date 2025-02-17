# Multi-Photon Quality Control with ScanImage

This repository contains various tools for measuring microscope performance with ScanImage. 
In particular, there are functions for recording and measuring Point Spread Functions (PSFs), 
and for measuring field of view size using an EM grid. 


## Main functions

* `mpsf.record.PSF` to easily acquire PSF stacks with ScanImage.
* `mpsf.record.lens_tissue` to acquire standardised data from lens tissue.
* `mpsf.record.standard_light_source` to data from a standard light source
* `measurePSF` to estimate PSF size. For a demo, run `measurePSF('demo')`. 
* `Grid2MicsPerPixel`  measures the number of microns per pixel along x and y by analyzing an image of an EM grid. 
* `mpsf_tools.meanFrame` plots the mean frame intensity as a function of time whilst you are scanning.


![cover image](https://raw.githubusercontent.com/SWC-Advanced-Microscopy/measurePSF/gh-pages/realBead.png "Main Window")


## Installation
Add the measurePSF `code` directory to your MATLAB path. 
You do not need to "Add With Subfolders".

### Fill in the settings file
Output files contain meta-data associated with the microscope in order to make it easier to compare different microscopes and to track hardware changes. 
Before using the tools for the first time **you must** run `mpsf.settings.readSettings;` and then **you must** fill in the YAML file for your PC. 
The commands which record information assume this file has been created and filled in with your microscope details. 
Future changes to the software may add fields to this file automatically. 
If this happens, it will be reported to the CLI that a new field was added with default settings. 
If you don't change the defaults, probably nothing bad will happen but the information provided by that field will not be logged. 


## Obtaining a PSF in ScanImage with averaging and fastZ
To get a good image of a sub-micron bead:
* Use image sizes of about 256x256 to 512x512 pixels.
* Once a bead is found, zoom to about 20x or 25x.
* Take a z-plane every 0.25 microns and average about 25 to 40 images per per plane. It's not worth doing more because we'll be fitting a curve to z-intensity profile.

To measure the PSF you can either use the included `mpsf.record.PSF` function or manually set up ScanImage (see `documentation` folder if you need to do that).

## Using `mpsf.record.PSF` to obtain a PSF
* Find a bead, zoom in. 
* Select only one channel to save in the [CHANNELS window](https://docs.scanimage.org/Windows%2BReference%2BGuide/Channels.html).
* Set the averaging to the quantity you wish to use in the [Image Controls](https://docs.scanimage.org/Windows%2BReference%2BGuide/Image%2BControls.html) window.
* Move the focus *down* to the lowest point you wish to image and press press "Zero Z" in MOTOR CONTROLS
* Now focus back up to where you want to start the stack and press "Read Pos" in MOTOR CONTROLS. 
This is the number of microns you will acquire (ignore the negative sign if present). 
* Run `mpsf.record.PSF` with number of microns obtained above as the first input argument. This will obtain the stack with a 0.25 micron resolution using the averaging you have set. e.g. `record.PSF(12)` for a 12 micron stack. The save location is reported to screen. You can define a different z resolution using the second input argument.


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


## Measuring field homogeneity
To record data:
```matlab
mpsf.record.uniform_slide
```
The results are saved to a folder on the desktop. You can view the results as follows:
```matlab
% cd to directory containing data
mpsf.plot.uniform_slide('uniform_slice_zoom_1_920nm_5mW__2022-08-02_10-09-33_00001.tif')
```

## Measuring electrical noise, and a standard light source
Remove all contaminant sources of light from the enclosure run:
```matlab
 mpsf.record.electrical_noise
```

Then place a standard light source under the objective and run:
```matlab
 mpsf.record.standard_light_source
```

## PDF report
You can generate a PDF report of all conducted analyses using 
```matlab
>> generateMPSFreport
```

### Requirements
The function has been well well-tested under R2016b and later. 
It should also work on R2016a. It's known to fail on 2015b and earlier.
Requires the Curve-Fitting Toolbox, the Image Processing Toolbox, and the Stats Toolbox.
The MATLAB Report Generator is needed if you want to make PDF reports.
It is known to work with ScanImage Basic 2020 to 2022 and likely earlier versions are also OK.

## Known Obvious Issues
Please see the [list of known obvious issues](https://github.com/SWC-Advanced-Microscopy/measurePSF/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22known%20obvious%20issues%22) before using the software. 


### Acknowledgments
###### Much of the early versions of this code were written in collaboration with [Fred Marbach](https://www.sainsburywellcome.org/web/people/fred-marbach) ([SWC](https://www.sainsburywellcome.org)), and Bruno Pichler and Mark Walling of [INSS](https://www.inss.org.uk/).
