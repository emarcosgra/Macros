/*Semi-automated macro to quantify the fluorescence of GFP+ axons of the somatosensory area in coronal sections of mouse cerebral cortex
    Copyright (C) <2023>  <Elia Marcos Grañeda> Contact: emgraneda@gmail.com
 
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>
    */
 
 //Choose the merged hyperstack to be opened
FilePath=File.openDialog("Select a File");
run("Bio-Formats Macro Extensions");
Ext.setId(FilePath);
Ext.getSeriesCount(seriesCount);
run("Bio-Formats Importer","open=&FilePath color_mode=Colorized view=Hyperstack stack_order=XYCZT series_"+seriesCount+"");
title=getTitle();
run("Split Channels");
selectWindow("C2-"+title);
run("Close");
selectWindow("C1-"+title);
waitForUser("Set the image and outline the S1-S2 and S2 columns, then the intermediate and medial regions.");
 
roiManager("Show All");
roiManager("Show None");
 
//Pre-processing
selectWindow("C1-"+title);
run("Threshold...");
waitForUser("set the threshold AND NOTE THE VALUES");
run("Convert to Mask");
rename("CL");
 
 
//Rename ROIs
function renarea(layer,name) {
	roiManager("Select",layer);
	roiManager("Rename",name);
}
 
renarea(0,"S1-S2");
renarea(1,"S2");
renarea(2,"IN");
renarea(3,"ME");


//Measure 
roiManager("Deselect");
dir=getDirectory("Image");
roiManager("Save", dir);
run("Set Measurements...", "area integrated mean display redirect=None decimal=3");
roiManager("Measure");
 
//Close all windows
waitForUser("When you finish, press OK to close all");
selectWindow("Results");
run("Close");
selectWindow("ROI Manager");
run("Close");
selectWindow("Threshold");
run("Close");
run("Close All");