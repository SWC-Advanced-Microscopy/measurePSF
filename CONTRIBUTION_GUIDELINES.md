# Contribution guidelines


## Basic stuff

### New files, attributions, and CHANGELOG
* Attribute changes to yourself in the `CHANGELOG.md` or in the last line of the DOC text _for files you created_.
So if you create a new function, at the bottom of the doc text add this: `NAME, INSTITUTE, initial commit DATE`    
e.g. all of these are ok: `John Blogs, SWC AMF, initial commit 2022` or `Jane Blogs, SWC AMF, initial commit Jan 2027`
* Do not add change info to individual files. e.g. do not add "file updated by Jody Blogs, Sept 2025". The Changelog should contain this information, along with what was changed. Feel free to add links to PRs and commits in the Changelog. 


### How to contribute: Forks and PRs
* Fork the repo.
* Make your changes in a new branch if you like (e.g. because the changes are extensive or will take a long time) or in the `dev` branch. Do not make changes in the `master` branch.  
* Add a section to the `CHANGELOG.md` the goes along these lines: 
```
### 2024/07/19
* NEW FEATURE: `mpsf.record` functions now all accept parameter/value pairs via standard interface.
Inputs that are required not supplied when the function is called are requested interactively at the CLI.
Isabell Whitely [PR #70](https://github.com/SWC-Advanced-Microscopy/measurePSF/pull/70).
```
* If you used a new branch: before filing a PR you should ensure your `dev` branch is up to date then merge into that. File the PR from `dev`. 



## Style Conventions
* Two spaces between methods in a class file.
* Comment block endings if they are large. e.g. `end % methods` at the end of methods blocks in a class file, as you typically can not see the methods at the start of the block at the same time as the `end`. 
* Try to keep class files below about 500 lines. 
* Short methods can remain in the main class file. 
* Longer methods should be in their own files.
* For consistency it is preferred to use a `@className` folder for all concrete classes even if there is only one `m` file in it. Short abstract classes can be left bare if desired to distinguish them from concrete classes.
* Unless there is an exceptional reason, all functions should be in a module sub-directory for neatness.
* Max line length is 100 characters but you can break this rule occasionally if that makes sense. It is better to sometimes have an exceptionally long line than to break up that line in an ugly and hard to read way. 
* Where possible follow the MATLAB editor's [checkcode](https://uk.mathworks.com/help/matlab/ref/checkcode.html) suggestions, but if doing so will make things ugly then feel free to ignore them. 
* Ident size should be 4 spaces (i.e. two indents should be 8 spaces). Do not use tabs. These are the settings used by default in the MATLAB editor.

## Format Guidelines
### Save files with Unix line endings. 
Sometimes these get switched to Windows endings by git. You can tell this has occurred because the Git client will show that all lines in a file are modified. Please do not commit these files: convert back to Unix line endings and commit. There is a Linux shell script in the project root folder that does this for the whole project, or use a text editor like [Sublime Text](https://www.sublimetext.com/), which makes it [easy to change the line endings](https://superuser.com/questions/1217622/how-can-i-remove-the-m-from-my-file-in-sublime-text-3). But the best thing is to  [set up Git to not mess with your line endings](https://troyready.com/blog/git-windows-dont-convert-line-endings.html).

