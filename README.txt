This Essentials folder contains the bare minimum bundle of MATLAB scripts which can perform a variety of data analysis and plotting methods on odor and laser experiments.

To use these scripts, place the '.kwik', '.dat', '.ns3', and '.kwx' files of the same recording in the same folder.

Example:

"FolderName" contents:
	'07-Jan-2016_005_bank1.kwik'
	'07-Jan-2016_005_bank1.dat'
	'07-Jan-2016_005.ns3'
	'07-Jan-2016_005_bank1.kwx'

Many scripts will take an input variable called 'KWIKfile'. This input must be a string containing the *full* path to the KWIK file (Example: KWIKfile='PathToFolder\FolderName\07-Jan-2016_005_bank1.kwik').

Add the Essentials folder and all subfolders onto the MATLAB path. To avoid having conflicts due to different versions of the same file being in the MATLAB path, take the OdorCode folder and all subfolders off of the MATLAB path. Also remove any other location where older versions of these scripts may be in from the path.

Refer to OdorCode Organization Google Spreadsheet for more information on specific scripts, and please note any bugs that arise during the use of these scripts.

Link to spreadsheet:
https://docs.google.com/spreadsheets/d/1sBcDjqrj5Tyxluxw1H-Ols12LCbpZrfV9_7as4wA77s/edit?usp=sharing