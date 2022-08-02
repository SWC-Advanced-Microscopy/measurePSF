# Recording the status of a microscope system

This is a protocol that can be performed regularly to monitor microscope parameters.
You will mostly be placing samples under the microscope then running a command. 
Apart from `measurePSF` the following commands will temporarily alter parameters in 
ScanImage in order to obtain a reasonable image. For example, the lens paper measurement
will go to zoom 2 and set a low resolution in order to produce a more uniform image that 
will not be too large (it records many frames). 

### Record laser power
Turn on the laser then wait half an hour before starting. 
Run through a range of laser power percentage values and record power at the objective in point mode. 
Do this for commonly used wavelengths and powers. e.g. 780 nm, 800 nm, and 920 nm. Currently this has to be
done manually.
Ensure you have a laser percentage value for 20 mW at 800m, 10 mW at 920, and around 5 mW at 920 nm.
We will use these later. 
If there is a very large change compared to last time you should investigate: is the beam being clipped, for instance. 


### Uniform slide
Place a uniform green slide under the objective. Find the surface and go down until the image no longer appears to change as you focus down. 
i.e. try to image as close to the surface as possible bearing in mind that your field is probably curved. Image at 920 nm 5 mW power. 
Record with the green PMT only at fairly low gain. Run:
```
record.uniform_slide(5,920)
```
If your laser power or wavelength is different then moldify the above command. 
Output saved in a `diagnostics` directory on the Desktop. 

### PSF
The ThorLabs is 1650 microns whereas the bead slide from Molecular Probes is 1010 microns. Swap out the slide and move the objective down by 650 micron (or whatever you measure your difference as being with calipers). 
Find a bead and take the stack with record.PSF. It's not a bad idea to measure beads at two or three points on the slide.
Use 920 nm 10 mW. You might want to use 15 mW or so for finding the beads then switch to 10 mW for imaging. Image with a FOV of about 80 microns at 512 by 512 pixels. That is a zoom of around 20 (+/- 5). Use 0.25 or 0.5 microns step size in Z. Usually 15 to 20 microns of imaged thickness is enough. 
Average at least 8 or 16 frames per optical plane with an 8 kHz reso scanner (just set Frame Rolling Average in ScanImage to the desired value).
Going up to about 40 frames per slice will yield nicer images if you care more about shape in x/y. For Z you are probably OK at the lower averaging values.
Data are saved to Desktop. 
Make sure you know the bead diamater. If in doubt, do not use the mixed size well.

Tips for finding beads:
* Place slide under objective with no water. Look from the front and side to ensure bead well is under objective. Then add water. 
* Set power to 30 mW, zoom 2 or 3, average 2 to 4 frames. 
* If it's helpful to have higher FPS, use 256 by 256 for searching. 
* Look both red and green channels.
* Usually there is a global increase in background when you are in the bead plane. 
* Zero the z motor when you find the beads or think you are getting there. This stop you from getting lost.
* Set power to 10 mW before zooming in or you will melt the larger beads. Molten beads will start to slowly expand, which will mean you can no longer image them. Often they will develop strange shapes. 

Once you have PSFs, use `measurePSF` to check them out. Don't proceed until you have decent images.


### Pause
If there are issues with the PSF or the field illumination then you might need to re-align and repeat before proceeding. 


### Lens paper
You will now image lens paper at 20 mW at 800 nm. You will need a slide that has mounted a small patch of lens paper. One layer only. 
It should have been coverslipped and sealed so it can't get wet. Find a reasonable FOV that has a decent amount of structure in it
and run

```
record.lens_paper(20,800)
```
It's a good idea to do about three FOVs. 
Results are saved to desktop. 

### Electrical noise
Run:
```
record.electrical_noise
```
