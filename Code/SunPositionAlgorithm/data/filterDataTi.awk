BEGIN {
	upperLimitVTEC = 0.3;
	lowerLimitVTEC = -0.3;
}
{
	/a/
	# 3 - time | 4 - recId | 5 - txId | 21 - d2li | 43 - xmappingion | 44 -xraion | 45 - xlation
	vtec = $21/$43;
	if (vtec >= lowerLimitVTEC && vtec <= upperLimitVTEC) {
		print $3 " " vtec " " $44 " " $45;	
	}
}
