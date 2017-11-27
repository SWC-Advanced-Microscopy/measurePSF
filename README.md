# measurePSF

MATLAB routine to measure a microscope point-spread function (PSF) based upon an image-stack of a sub-micron bead. 
To run, add measurePSF to your path or `cd` to the directory containing the file. To run a demo, just run the command `measurePSF`. You should then get a figure window much like the one below. Read the help text. 

The repository also contains `Grid2MicsPerPixel`, which can be used to measure the number of microns per pixel along x and y by analysing an image of an EM grid. 

The function has been well tested under R2016b. It should also work on R2014b and later. 


![cover image](https://raw.githubusercontent.com/raacampbell/measurePSF/gh-pages/realBead.png "Main Window")


# Change-Log
* 27th Nov 2017 -- Convert `measurePSF` to a class so adding new features is easier.