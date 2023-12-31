/*Semi-automated macro to quantify the number and distribution of GFP+ neurons between somatosensory areas (S1 and S2) in coronal sections of mouse cerebral cortex
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

//Reduce background noise
title=getTitle();
run("FFT");
waitForUser("Set oval")
setBackgroundColor(0, 0, 0);
run("Clear", "slice");
title1=getTitle();
run("Inverse FFT");
selectWindow(title1);
run("Close");
waitForUser("Set the image and outline the S1 IUE, then separate L1, L2/3 and L4 within. Repeat the process for S2");
roiManager("Show All");
roiManager("Show None");

//Pre-processing
selectWindow("Inverse FFT of " + title);
run("RGB Color");
run("HSB Stack");
run("Convert Stack to Images");
selectWindow("Hue");
run("Close");
selectWindow("Saturation");
run("Close");

selectWindow("Brightness");
percentage = 0.02;
target = (1-percentage)*getWidth()*getHeight();
nBins = 256;
getHistogram(values,counts,nBins);
sum = 0; threshold = -1;
for(i=0; i<nBins; i++){
  sum += counts[i];
  if( (sum >= target) & (threshold < 0) ){ threshold = i; }
  }
setThreshold(threshold, 255);
run("Threshold...");

waitForUser("set the threshold AND NOTE THE VALUES");
run("Convert to Mask");
run("Make Binary");
run("Invert");
run("Adjustable Watershed", "tolerance=0.3");
run("Median...", "radius=0");
run("Median...", "radius=0");
rename("Processed");
 
//Eliminate space outside the electroporated area
roiManager("Select",newArray(0,4));
roiManager("Combine");
run("Clear Outside");
 
//Rename ROIs
function renLayers(layer,name) {
	roiManager("Select",layer);
	roiManager("Rename",name);
}
 
renLayers(0,"S1");
renLayers(1,"S1L1");
renLayers(2,"S1L2/3");
renLayers(3,"S1L4");
renLayers(4,"S2");
renLayers(5,"S2L1");
renLayers(6,"S2L2/3");
renLayers(7,"S2L4");

roiManager("Deselect");
dir=getDirectory("Image");
roiManager("Save", dir);
 
//Count GFP cells/layer
function GFP_layer(layer,c,name) {	
	selectWindow("Processed");
	roiManager("Show None");
	roiManager("Show All");
	run("Duplicate...","Processed");
	rename(name);
	roiManager("Select",layer);
	run("Analyze Particles...","size=60-600 circularity=0.3-1 show=Outlines display summarize add in_situ");
 
		//Rename ROIs with the layer and number of electroporated neurons
		bproi = roiManager("count");
		roiname=name+"-";
		for (i=c;i<bproi;i++){
     	   roiManager("select", i);
     	   roiManager("rename",roiname+i-7);
		}
}
 
GFP_layer(1,8,"S1L1");
GFP_layer(2,8+nResults,"S1L2/3");
GFP_layer(3,8+nResults,"S1L4");
GFP_layer(5,8+nResults,"S2L1");
GFP_layer(6,8+nResults,"S2L2/3");
GFP_layer(7,8+nResults,"S2L4");
 
selectWindow("Results");
run("Close");
 
//Close all the "processed" images
while (nImages>3) { 
	selectImage(nImages); 
    close(); 
} 
 
waitForUser("Check the ROIs and eliminate the inappropriate ones");
roiManager("deselect");
 
//Re-count after adjustment
function findRoisWithName(roiName) { 
	nR = roiManager("Count"); 
	roiIdx = newArray(nR); 
	k=0; 
	clippedIdx = newArray(0); 
	 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName) ) { 
			roiIdx[k] = i; 
			k++; 
		} 
	} 
	if (k>0) { 
		clippedIdx = Array.trim(roiIdx,k);
		Positions=Array.print(clippedIdx); 
	}
	print(k);
//	return Positions;
} 
 
//To obtain ROI names CONTAINING your search use ".*name.*"
findRoisWithName(".*S1L1-.*");
findRoisWithName(".*S1L2/3-.*");
findRoisWithName(".*S1L4-.*");
findRoisWithName(".*S2L1-.*");
findRoisWithName(".*S2L2/3-.*");
findRoisWithName(".*S2L4-.*");

roiManager("Deselect");
dir=getDirectory("Image");
roiManager("Save", dir);
 
//Close all windows
waitForUser("When you finish, press OK to close all");
selectWindow("Log");
run("Close");
selectWindow("Summary");
run("Close");
selectWindow("ROI Manager");
run("Close");
selectWindow("Threshold");
run("Close");
run("Close All");