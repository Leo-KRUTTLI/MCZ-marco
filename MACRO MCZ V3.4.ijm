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

// MERGE
 if (mergeChecked) {

showMessage("click on *OK* to choose input folder");
input1 = getDirectory("choose input folder"); // Choose the folder with bases image
print(input1);

showMessage("click on *OK* to choose output folder");
output1 = getDirectory("choose output folder"); // Choose the folder with bases image
print(output1);


list1 = getFileList(input1);

options = newArray("Red", "Green", "Blue", "Magenta", "Yellow", "Cyan", "Grays", "None");
channels = newArray("Channel 1", "Channel 2", "Channel 3", "Channel 4", "Channel 5");

option = newArray( "ND", "LIF");

Dialog.create("Choose image type");
Dialog.addMessage("Select the image type");
Dialog.addChoice("Image Type", option, option[0]);
Dialog.show();

imageTypeChoice = Dialog.getChoice();

for (i=0; i<list1.length; i++){
	if ((imageTypeChoice == "ND" && endsWith(list1[i], ".nd")) || 
        (imageTypeChoice == "LIF" && endsWith(list1[i], ".lif"))) {
            
            
            if (imageTypeChoice == "LIF") {
                
var svccCounter = 0;
    file = input1 + list1[i];

run("Bio-Formats Macro Extensions");

Ext.setId(file);

Ext.getSeriesCount(nSeries);
seriesToOpen = newArray(nSeries);  // Initialisation du tableau avec une taille appropriée
sIdx = 0;

// Boucle pour ajouter toutes les séries à ouvrir
for (i = 0; i < nSeries; i++) {
    seriesToOpen[sIdx++] = i + 1;  // Ajouter toutes les séries, en utilisant un index ajusté de +1
}

Array.print(seriesToOpen);

for (s = 0; s < seriesToOpen.length; s++) {
    run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_list=" + seriesToOpen[s]);
setBatchMode(true); //turn on batch mode.
 if (s == 0) {
 	setBatchMode(false); //turn off batch mode.
 	run("Channels Tool...");
                    waitForUser("Note your channels color \nThen press OK");
                    Dialog.create("Merge channels");
                    Dialog.addMessage("Choose the color for your channels");
                    for (k = 0; k < 5; k++) {
                        Dialog.addChoice(channels[k], options, options[7]);
                    }
                    Dialog.show();
                    channelColors = newArray();
                    for (k = 0; k < 5; k++) {
                        channelColors[k] = Dialog.getChoice();
                    }
                    selectWindow("Channels");
                    run("Close");
                }
                // Set up the composite mode for the image
		        imageTitle1 = File.nameWithoutExtension;
		        imageTitle1bis = getTitle();
                Property.set("CompositeProjection", "Sum");
                Stack.setDisplayMode("composite");

                // Apply the selected channel colors
                for (k = 0; k < 5; k++) {
                    if (channelColors[k] != "none") {
                        Stack.setChannel(k + 1);
                        run(channelColors[k]);
                    }
                }

 if (imageTitle1bis.endsWith("SVCC")) {
        // Save the image with "svg" in the filename and same sequence number
        svccCounter++;
        saveAs("Tiff", output1 + "MERGE_" + imageTitle1 + "_" + (s + 1 - svccCounter) + "_SVCC");
    } else {
                // Save the image with the prefix "MERGE_"                
                saveAs("Tiff", output1 + "MERGE_" + imageTitle1 + "_" + (s + 1 - svccCounter));
}
run("Close All");
}
}
if (imageTypeChoice == "ND") {
run("Bio-Formats Importer", "open=[" + input1 + list1[i] + "] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");	
setBatchMode(true); //turn on batch mode.	
		if (list1[i]==list1[0]) {
			setBatchMode(false); //turn on batch mode.
			// Get user choices for channel colors
			run("Channels Tool...");
                waitForUser("Note your chanels color \nThen press OK");
                Dialog.create("Merge channels");
                Dialog.addMessage("Choose the color for your channels");
                for (j = 0; j < 5; j++) {
                    Dialog.addChoice(channels[j], options, options[7]);
                }
                Dialog.show();
                channelColors = newArray();
                for (j = 0; j < 5; j++) {
                    channelColors[j] = Dialog.getChoice();
                }
                selectWindow("Channels");
                    run("Close");
            }		
		imageTitle1 = File.nameWithoutExtension;
            Property.set("CompositeProjection", "Sum");
            Stack.setDisplayMode("composite");

            for (j = 0; j < 5; j++) {
                if (channelColors[j] != "none") {
                    Stack.setChannel(j + 1);
                    run(channelColors[j]);
                }
            }
		// Save with the original name with MERGE_ in front
		saveAs("Tiff", output1 + "MERGE_" + imageTitle1);
		run("Close All");
	}
	}
}
}

// CROP
if (cropChecked) {
setBatchMode(false);

if (!mergeChecked) {
   showMessage("click on *OK* to choose input folder");
input2 = getDirectory("choose input folder"); // Choose the folder with bases image
print(input2);

showMessage("click on *OK* to choose output folder");
output2 = getDirectory("choose output folder"); // Choose the folder with bases image
print(output2);

option = newArray("TIF", "ND", "LIF");

Dialog.create("Choose image type");
Dialog.addMessage("Select the image type");
Dialog.addChoice("Image Type", option, option[0]);
Dialog.show();

imageTypeChoice = Dialog.getChoice();

    }
    
else {
input2 = output1 ;

showMessage("click on *OK* to choose output folder");
output2 = getDirectory("choose output folder"); // Choose the folder with bases image
print(output2);

imageTypeChoice = "TIF";
}

list2 = getFileList(input2);

for (i=0; i<list2.length; i++){
	if (imageTypeChoice == "TIF") {
	if (endsWith(list2[i], ".tif") ) {
    open(input2 + list2[i]);
    imageTitle = getTitle;
crop(imageTitle);}}

    if (imageTypeChoice == "ND") {
	if (endsWith(list2[i], ".nd") ) {
run("Bio-Formats Importer", "open=[" + input2 + list2[i] + "] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
imageTitle = getTitle;
crop(imageTitle);}}
    
    
    if (imageTypeChoice == "LIF") {
	if (endsWith(list2[i], ".lif") ) {
    var svccCounter = 0;
    file = input2 + list2[i];
run("Bio-Formats Macro Extensions");
Ext.setId(file);
Ext.getSeriesCount(nSeries);
seriesToOpen = newArray(nSeries);  // Initialisation du tableau avec une taille appropriée
sIdx = 0;
// Boucle pour ajouter toutes les séries à ouvrir
for (i = 0; i < nSeries; i++) {
    seriesToOpen[sIdx++] = i + 1;  // Ajouter toutes les séries, en utilisant un index ajusté de +1
}
Array.print(seriesToOpen);
for (s = 0; s < seriesToOpen.length; s++) {
    run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_list=" + seriesToOpen[s]);
imageTitle = getTitle;
crop(imageTitle);
}}}
 
    function crop(imageTitle) {
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
        savetitle2 = replace(originalImageTitle, ".tif", "");
        saveAs("Tiff", output2 + "CROP_" + savetitle2 + "_ROI" + roi+1);
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
setBatchMode(false);

if (!cropChecked) {
        if(!mergeChecked) {
        	showMessage("click on *OK* to choose input folder");
input3 = getDirectory("choose input folder"); // Choose the folder with bases image
print(input3);
showMessage("click on *OK* to choose output folder");
output3 = getDirectory("choose output folder"); // Choose the folder with bases image
print(output3);
option = newArray("TIF", "ND", "LIF");
Dialog.create("Choose image type");
Dialog.addMessage("Select the image type");
Dialog.addChoice("Image Type", option, option[0]);
Dialog.show();
imageTypeChoice = Dialog.getChoice();
        }
        else {
input3 = output1;
showMessage("click on *OK* to choose output folder");
output3 = getDirectory("choose output folder"); // Choose the folder with bases image
print(output3);
imageTypeChoice = "TIF";
        }
}
else {
input3 = output2;
showMessage("click on *OK* to choose output folder");
output3 = getDirectory("choose output folder"); // Choose the folder with bases image
print(output3);
imageTypeChoice = "TIF";
}

filePath = output3 + "stack data.csv";  // CSV file name

// Open or create the CSV file
// Vérifier si le fichier CSV existe déjà
csvContent = "";
if (File.exists(filePath)) {
    // Lire le contenu existant pour l'ajouter ensuite
    csvContent = File.openAsString(filePath);
} else {
    // Si le fichier n'existe pas, ajouter l'en-tête des colonnes
    csvContent = "Imagename" + "," + "zBeg" + "," + "zEnd" + "\n";
}
File.saveString(csvContent, filePath);

list3 = getFileList(input3);

projectionType = newArray("Max Intensity", "Sum Slices", "Min Intensity", "Average Intensity", "Standard Deviation", "Median");
        Dialog.create("Select Projection Type");
        Dialog.addChoice("Projection Type:", projectionType, projectionType[0]);
        Dialog.show();
        
        // Récupérer le choix de l'utilisateur
        projectionTypechoice = Dialog.getChoice();

for (i=0; i<list3.length; i++){
	
	if (imageTypeChoice == "TIF") {
	if (endsWith(list3[i], ".tif") ) {
 open(input3 + list3[i]);
    imageTitle4 = getTitle();
    imagename = getTitle();
zproj(imageTitle4);}}

    if (imageTypeChoice == "ND") {
	if (endsWith(list3[i], ".nd") ) {
run("Bio-Formats Importer", "open=[" + input3 + list3[i] + "] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
    imageTitle4 = getTitle();
    imagename = getTitle();
zproj(imageTitle4);}}
    
    
    if (imageTypeChoice == "LIF") {
	if (endsWith(list3[i], ".lif") ) {
    var svccCounter = 0;
    file = input3 + list3[i];
run("Bio-Formats Macro Extensions");
Ext.setId(file);
Ext.getSeriesCount(nSeries);
seriesToOpen = newArray(nSeries);  // Initialisation du tableau avec une taille appropriée
sIdx = 0;
// Boucle pour ajouter toutes les séries à ouvrir
for (i = 0; i < nSeries; i++) {
    seriesToOpen[sIdx++] = i + 1;  // Ajouter toutes les séries, en utilisant un index ajusté de +1
}
Array.print(seriesToOpen);
for (s = 0; s < seriesToOpen.length; s++) {
    run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_list=" + seriesToOpen[s]);
    imageTitle4 = getTitle();
    imagename = getTitle();
zproj(imageTitle4);
}}}

function zproj(imageTitle4) {
waitForUser("Choose first projection plane");
Stack.getPosition(channel, zBeg, frame);
setResult("z.beg", nResults, zBeg);
updateResults();
wait(20); //to avoid an annoying bug due to parallel processing
waitForUser("Choose last projection plane");
Stack.getPosition(channel, zEnd, frame);
setResult("z.end", nResults, zEnd);
updateResults();
imagename = getTitle();
csvContent = File.openAsString(filePath);
csvContent += imagename + "," + zBeg + "," + zEnd + "\n";
File.saveString(csvContent, filePath);
        if (projectionTypechoice == "Max Intensity") {
            run("Z Project...", "start=zBeg stop=zEnd projection=[Max Intensity]");
        } 
        if (projectionTypechoice == "Sum Slices") {
            run("Z Project...", "start=zBeg stop=zEnd projection=[Sum Slices]");
        } 
        if (projectionTypechoice == "Min Intensity") {
            run("Z Project...", "start=zBeg stop=zEnd projection=[Min Intensity]");
        } 
        if (projectionTypechoice == "Average Intensity") {
            run("Z Project...", "start=zBeg stop=zEnd projection=[Average Intensity]");
        }
        if (projectionTypechoice == "Standard Deviation") {
            run("Z Project...", "start=zBeg stop=zEnd projection=[Standard Deviation]");
        }
        if (projectionTypechoice == "Median") {
            run("Z Project...", "start=zBeg stop=zEnd projection=[Median]");
        }
        
    imageTitle4=getTitle;
    savetitle2 = replace(imageTitle4, ".tif", "");
   saveAs("Tiff", output3 + savetitle2);
        close(); 
    run("Close All");
}
}
}