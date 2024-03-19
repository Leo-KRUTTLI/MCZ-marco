# Version 27 March 2024
# By Léo KRÜTTLI

// Determine the image processing steps to run 
Dialog.create("Choice of steps");
Dialog.addMessage("Choose your steps");
Dialog.addCheckbox("Merge", false);
Dialog.addCheckbox("Crop", false);
Dialog.addCheckbox("Projection Z", false);
Dialog.show();

// Get user choices
mergeChecked = Dialog.getCheckbox();
cropChecked = Dialog.getCheckbox();
projectionZChecked = Dialog.getCheckbox();
  
dir1 = getDirectory("choose input folder with bases images"); // Choose the folder with bases image
print(dir1)

// MERGE
color = "color"
red = "c1"
green = "c2"
blue = "c3"
gray = "c4"
cyan = "c5"
magenta = "c6"
yellow = "c7"

 if (mergeChecked) {

// Create a new repertory to save merge
dir2 = dir1 + "merge" + File.separator ;
newDirName = "merge";
newDirPath = dir2;
File.makeDirectory(newDirPath);


list1 = getFileList(dir1);

for (i=0; i<list1.length; i++){
	if (endsWith(list1[i], ".nd") ){
		open(dir1 + list1[i]); // Open .nd images
		
		if (list1[i]==list1[0]) {
			waitForUser("Note your chanels color \nThen press OK");
            // Determine the colors for the merge
            Dialog.create("Merge channels");
            options = newArray("red", "green", "blue", "gray", "none");
            Dialog.addMessage("choose the color your Channels");
            Dialog.addChoice("Channel 1", options, options[4]);
            Dialog.addChoice("Channel 2", options, options[4]);
            Dialog.addChoice("Channel 3", options, options[4]);
            Dialog.addChoice("Channel 4", options, options[4]);
            Dialog.addChoice("Channel 5", options, options[4]);
            Dialog.show();
            // Get user choices
            CH1 = Dialog.getChoice();
            CH2 = Dialog.getChoice();
            CH3 = Dialog.getChoice();
            CH4 = Dialog.getChoice();
            CH5 = Dialog.getChoice();
		}
		
		imageTitle1 = getTitle;
		run("Duplicate...", "title=Dupli.tif duplicate"); // Duplicate the image and rename it "Dupli."
		selectImage("Dupli.tif");
		run("Split Channels");
		selectWindow("C1-Dupli.tif");
		 // Make the merge
        run("Merge Channels...", CH1 + "=C1-Dupli.tif " + CH2 + "=C2-Dupli.tif " + CH3 + "=C3-Dupli.tif " + CH4 + "=C4-Dupli.tif "+ CH5 + "=C5-Dupli.tif create");
         // Save with the original name with _MERGE
		tmp1=replace(imageTitle1, ".TIF", "_");
        clean_name1=replace(tmp1, " ", "_");
        print(dir2);
        print(dir2+ clean_name1 + "MERGE"+ ".tif");
        save(dir2+ clean_name1 + "MERGE" + ".tif");
		run("Close All");
	}
}
}

// CROP
// adapted from https://github.com/CentrioleLab/CropAndResize/blob/main/CropAndResize_.ijm macro
if (cropChecked) {


if (!mergeChecked) {
        dir2 = dir1 ;
        dir3 = dir1 + "crop" + File.separator ;
        // Create a new repertory to save crop
        newDirName = "crop";
        newDirPath = dir3;
        File.makeDirectory(newDirPath)
    }
    
else {
dir3 = dir2 + "crop" + File.separator ;
// Create a new repertory to save crop
newDirName = "crop";
newDirPath = dir3;
File.makeDirectory(newDirPath);
}

list2 = getFileList(dir2);

for (i=0; i<list2.length; i++){
	if (endsWith(list2[i], ".tif") ) {
    open(dir2 + list2[i]);
    originalImageTitle = getTitle;
    run("Duplicate...", "title=Dupli.tif duplicate"); // Duplicate the image and rename it "Dupli."
    selectImage("Dupli.tif");
    makeRectangle(0, 0, 80, 80); // Create a Rectangle on the duplicate image
    // Open ROI manager
    run("ROI Manager...");
    // Wait for user to add his ROI to ROI manager
    waitForUser("Create the ROIs on your image and add them to ROI manager. Then press OK");
    //Get total ROIs number
    nROIs = roiManager("count");
    // Browse each ROI
    
    for (roi=0; roi<nROIs; roi++) {
        // Select curent ROI
      selectImage(originalImageTitle);  
      run("Duplicate...", "title=Dupli.tif duplicate"); // We duplicate the image and rename it "Dupli."
	  selectImage("Dupli.tif");
      roiManager("select", roi);
        // Crop duplicate image
        run("Crop");
        imageTitle2 = getTitle; 
        // Get image dimensions
        getDimensions(width, height, channels, slices, frames);
        // Resize the image
        run("Canvas Size...", "width=" + width*6 +" height=" + width*6 +" position=Center zero");
        // Scale the image
        run("Scale...", "x=6 y=6 z=1.0 interpolation=Bilinear average" );
        run("Set Scale...", "known=" + 1/6 +" pixel=1");
        // Save with the original name with _CROPPED + nroi
        tmp2 = replace(originalImageTitle, "_MERGE.tif", "_");
        clean_name2 = replace(tmp2, " ", "_");
        print(dir3);
        print(dir3 + clean_name2 + "CROPPED_" + roi + ".tif");
        save(dir3 + clean_name2 + "CROPPED_" + roi + ".tif");
        close();
    }
selectWindow("ROI Manager");
run("Close");
run("Close All");
}
}
}

// Z PROJECTION
if (projectionZChecked) {

// Create a new repertory to save z projection


if (!cropChecked) {
        if(!mergeChecked) {
        	dir3=dir1 ;
        	dir4 = dir1 + "z project" + File.separator ;
            newDirName = "z project";
            newDirPath = dir4;
            File.makeDirectory(newDirPath);
        }
        else {
        	dir3 = dir2 ;
            dir4 = dir2 + "z project" + File.separator ;
            newDirName = "z project";
            newDirPath = dir4;
            File.makeDirectory(newDirPath);
        }
    }

else {
dir4 = dir3 + "z project" + File.separator ;
newDirName = "z project";
newDirPath = dir4;
File.makeDirectory(newDirPath);
}

list3 = getFileList(dir3);

for (i=0; i<list3.length; i++){
	if (endsWith(list3[i], ".tif") ) {
    open(dir3 + list3[i]);
    imageTitle3=getTitle;
    waitForUser("Check your z Start \nWhen it's done press OK");
    zstart = getNumber("Enter z Start value:", 1);
    waitForUser("Check your z Stop \nWhen it's done press OK");
    zstop = getNumber("Enter z Stop value:", 100);
    run("Z Project...", "start=zstart stop=zstop projection=[Max Intensity]");
    // Save with the original name with _ZPROJ
    tmp3=replace(imageTitle3, "(.tif|_MERGE.tif)", "_");
    clean_name3=replace(tmp3, " ", "_");
    print(dir4);
    print(dir4+ clean_name3 + "ZPROJ" + ".tif");
    save(dir4+ clean_name3 + "ZPROJ" + ".tif");
    run("Close All");
}
}
}
