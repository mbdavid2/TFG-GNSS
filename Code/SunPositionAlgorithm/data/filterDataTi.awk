BEGIN {
	upperLimitVTEC = 10;
	lowerLimitVTEC = -10;
}
{
	/a/
	# 3 - time | 4 - recId | 5 - txId | 21 - d2li | 43 - xmappingion | 44 -xraion | 45 - xlation |||||| 47 - rasun | 48 - decsun
	vtec = $21/$43;
	# if (vtec >= lowerLimitVTEC && vtec <= upperLimitVTEC) {
		print $3 " " vtec " " $44 " " $45;	
	# }
}
