# Peters-AFM-Analysis

This is a repository which contains the code used to analyze data in the lab of Dr. Justin Peters at the
University of Northern Iowa

Through May of 2020, it was written by Joseph Tibbs, in support of his Honors Undergraduate Thesis work

The code file "AFMAnalyze" is the main function; it is designed to extract data from microscope images taken from
an Agilent 5500 SPM atomic force microscope which have been saved in ASCII format.  Unfortunately, I never figured out
how to convert an arbitrary .mi file to ASCII or csv without just opening it in picoview and hitting 'save as'.

One more piece of code which might be useful for future analysis would be the automation script for the AFM itself
It was written in python and stored (in a few versions, depending on how many repetitions I wanted to do) on the 
AFM computer in a python file.  Unfortunately, I don't have access to it at this time, but maybe a copy of it will 
show up in this repository sometime?  It's not that hard to make, you just have to call 'set.scanXOffset(x_in_m)' 
(and similarly for y) within a for loop that has a 'while getSanningStatus: wait 1 second' or similar.  The other
things to make sure of when doing this coding is that you have all of your scan parameters set before you run the
automation code (maybe even have the tip engaged, though you can have it approach automatically), set your save settings
before you start, set it to scan 1 frame (not infinity, as is the default), and set autosave to after every frame.  
Also, the AFM we have really seems to drift when you change the tip position so I always had to shift it, scan for a minute,
then restart the scan, because otherwise these really large shear artifacts would appear in the image.

Joseph can be contacted (for a while, anyway) at jtibbs2@illinois.edu
