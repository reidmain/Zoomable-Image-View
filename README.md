Overview
========
While working on a project I had the need to display an image on the iPad that was four times the size of the non-Retina iPad resolution. The image was approximately 2MB in size so when I loaded it using \[UIImage +imageNamed\] the UI thead would lock for for a noticable amount of time.

After some investigation I came to the conclusion that the using [CATiledLayer](http://developer.apple.com/library/ios/#documentation/GraphicsImaging/Reference/CATiledLayer_class/) was the solution to my problem. I could cut the image up into tiles using a script and then load them async in a background thread so it wouldn't block the UI thread.

After finishing the project I realized that I could have also loaded the entire image into memory in a background thread and then add it to UIScrollView. I decided to create a reusable control that would have both of these features.

That control is called FDZoomableImageView and this project is an example of how to implement it. This project should build out of the box and be able to run on any iOS device or the iOS simulator.

Installation
============
To use the FDZoomableImageView control you will need to copy the following files to your project:

FDZoomableImageView.h  
FDZoomableImageView.m  
FDTiledImageView.h  
FDTiledImageView.m  
FDNullOrEmpty.h  
NSObject+PerformBlock.h  
NSObject+PerformBlock.m  
UIView+Layout.h  
UIView+Layout.m  

Usage
=====
To use the FDZoomableImageView control simply instantiate it like you would UIScrollView (either in code or in a nib) and then call the appropriate method to set the image.

A script called 'tile_slicer' has been included with the project which will assist you in cutting up any images you want to display using the tiling mechanism. This script assumes that you have [ImageMagick](http://www.imagemagick.org/) installed and accessible via the $PATH variable. If you are uncomfortable compiling and installing ImageMagick yourself I'd recommand a package manager such as [MacPorts](http://www.macports.org/)
