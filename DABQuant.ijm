/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

setBatchMode(true); //batch mode on
processFolder(input);
setBatchMode(false); //exit batch mode

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print(file);
	bioFormatsInstruct = "open=" + input + File.separator + file + " autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_2";
	//print(string);
	run("Bio-Formats Importer", bioFormatsInstruct);
	run("Stack to RGB");
	run("Colour Deconvolution", "vectors=[H DAB]");
	close();
	run("8-bit");
	saveAs("Tiff", output + File.separator + file);
	run("Measure");
	setAutoThreshold("Default dark");
	//originally 165, 255
	setThreshold(200, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	saveAs("Tiff", output + File.separator + "thresh" + file);
	run("Select None");
	run("Create Selection");
	run("Make Inverse");
	run("Measure");
	saveAs("Results", output + File.separator + "2020_09_08_HPQuants.csv");
	print("Processing: " + input + File.separator + file);
	print("Saving to: " + output);
}
