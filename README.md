# measurePSF

MATLAB routine to measure a microscope point-spread function (PSF) based upon an image-stack of a sub-micron bead. 
To run, add measurePSF to your path or `cd` to the directory containing the file. To run a demo, just run the command `measurePSF`. You should then get a figure window much like the one below. Read the help text. 

The repository also contains `Grid2MicsPerPixel`, which can be used to measure the number of microns per pixel along x and y by analyzing an image of an EM grid. 

## Obtaining a PSF in ScanImage with averaging and fastZ
To get a good image of sub-micron bead I generally zoom to about 20x or 25x and use an image size of 256 by 256 pixels. 
I take z-plane every 0.25 microns and average about 25 to 40 images per per plane. 
It's not worth doing more because we'll be fitting a curve to z-intensity profile.
To measure the PSF you can either use the included `recordPSF` function or manually set up ScanImage. 

## Using `recordPSF` to obtain a PSF
* Find a bead, zoom in. 
* Select only one channel to save in the CHANNELS window.
* Set the averaging to the quantity you wish to use.
* Move the focus *down* to the lowest point you wish to image and press press "Zero Z" in MOTOR CONTROLS
* Now focus back up to where you want to start the stack and press "Read Pos" in MOTOR CONTROLS. 
This is the number of microns you will acquire (ignore the negative sign if present). 
* Run `recordPSF` with number of microns obtained above as the first input argument. This will obtain the stack with a 0.25 micron resolution using the averaging you have set. e.g. `recordPSF(12)` for a 12 micron stack. The save loction is reported to screen. You can define a different z resolution using the second input argument. 

To view the PSF you would do something like:
```
>> [~,TT]=scanimage.util.opentif('PSF_2018-31-09_12-11-21_00001.tif');
>> size(TT)

ans =

   256   256     1     1    64

>> TT= squeeze(TT);
>> measurePSF(TT,0.25);
>> 
```


## Manually setting up ScanImage to record a PSF with averaging
These instructions explain how to set up ScanImage to obtain an averaged fast z stack. 
These instructions are pretty much what `recordPSF` does, so if that's not working for you just follow the steps below.

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

## Measuring FOV size with an EM grid
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
Requires the Curve-Fitting Toolbox, the Image Processing Toolbox, and the Stats Toolbox.


![cover image](https://raw.githubusercontent.com/raacampbell/measurePSF/gh-pages/realBead.png "Main Window")


# Change-Log
* 2020/01/13 -- Convert Grid2MicsPerPixel to a class and add buttons to interact with SI (v3.45)
* 2020/01/08 -- Grid2MicsPerPixel optionally can extract the grid image directly from ScanImage (v1.45)
* 2018/11/09 -- Add `recordPSF` (v1.0)
* 2017/11/28 -- Simple GUI for interactive cropping of a desired bead.
* 2017/11/28 -- Improve output data and don't display FWHM for directions in which the user defined no microns per pixel.
* 2017/11/27 -- Convert `measurePSF` to a class so adding new features is easier.
