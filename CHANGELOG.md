
# Change-Log

### DEV-BRANCH-DATE-ADDED-WHEN-MERGED
* General doc text tidying. 
* Add `CONTRIBUTION_GUIDELINES.md`
* Make a standalone `CHANGELOG.md` then tidy it and improve formatting.
* Rename repo to multiphoton-qc, mpsf -> mpqc

### 2024/07/19
* NEW FEATURE: `mpsf.record` functions now all accept parameter/value pairs via standard interface.
Inputs that are required not supplied when the function is called are requested interactively at the CLI.
Isabell Whitely [PR #70](https://github.com/SWC-Advanced-Microscopy/measurePSF/pull/70).


### 2024/07/05
* Updates to standard light source. Plotting of said. Bugfixes.

### 2024/06/14
* NEW FEATURE: Add standard light source function. Add dark noise to electrical noise.

### 2024/05/23
* Implement a more elaborate microscope settings (parameters) system.

### 2023/07/31
* NEW FEATURE: Integrate functionality of making PDF reports, uniform slide analyses, and plots of lens paper. 

### 2022/08/02
* NEW FEATURE: Add function for imaging electrical noise and document protocol.

### 2022/08/01
* NEW FEATURE: Add functions for recording lens paper and uniform slides.

### 2020/02/19
* Add tiff stack name to title of top right plot.

### 2020/02/18
* Tidy `measurePSF` PDF and add dummy values to demo mode.

### 2020/02/18
* Bug fixes, check coarse z acquisition works, add PDF saving.

### 2020/02/12
* Bugfixes

### 2020/01/30
* Add `mpsf_tools.meanFrame` for displaying a rolling frame average.

### 2020/01/14
* Add button that allows the current image to be saved to the desktop.

### 2020/01/14
* Add edit boxes and checkboxes to allow the user to modify on the fly what would otherwise have been input arguments.

### 2020/01/14
* Get voxel size from ScanImage TIFF header.

### 2020/01/14
* If no input args to `measurePSF`, bring up the load GUI.

### 2020/01/13
* Convert Grid2MicsPerPixel to a class and add buttons to interact with SI.

### 2020/01/08
* Grid2MicsPerPixel optionally can extract the grid image directly from ScanImage.

### 2018/11/09
* Add `record.PSF`.

### 2017/11/28
* Simple GUI for interactive cropping of a desired bead.

### 2017/11/28
* Improve output data and don't display FWHM for directions in which the user defined no microns per pixel.

### 2017/11/27
* Convert `measurePSF` to a class so adding new features is easier.



