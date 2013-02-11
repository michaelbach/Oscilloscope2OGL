Oscilloscope2OGL
================

A simple multi-channel "oscilloscope" for MacOS. Similar to Oscilloscope3, but using OpenGL.


This oscilloscope can have one or up to kOscilloscopeMaxNumberOfTraces traces (preset to 8).
Most calls are availabe in both single- and multichannel mode.
 
The oscilloscope advances 1 point in device space per call (advanceWithSample(s))

Entire sweeps can also be displayed with setTrace:toSweep: / setSingleTraceToSweep:

0 is in the vertical center, the vertical scaling is addressed by calling setMaxPositiveValue:.
 

To insert into your program
---------------------------
* In your controller class: create an Oscilloscope2* IBOutlet.
* In Interface Builder: instantiate an NSOpenGLView, set it's class to Oscilloscope2OGL, then connect.


Options
-------
* choose trace and background colours
* choose separator lines between traces
* dashed zero line


