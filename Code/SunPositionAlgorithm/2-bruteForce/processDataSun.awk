NR==1 {
	arrayInfo["test"][0] == 3;
}
{
	/a/
 	groupByTime();
}

END{
	# printSpecificTime("11.033333333333");
	# printSpecificTime("11.041666666667");
 	printSpecificTime("11.050000000000");
 	# printSpecificTime("11.058333333333");
}

function groupByTime() {
	infoType = 3;
	timeIndex = $3;
	filter = false;
	if (filter == flase || $4 == "vill") {
		if (arrayInfo[timeIndex][0] == "") {
			info = getInfo(timeIndex, infoType, currentLength);
			arrayInfo[timeIndex][0] = info;
		}
		else {
			currentLength = length(arrayInfo[timeIndex])
			info = getInfo(timeIndex, infoType, currentLength);
			arrayInfo[timeIndex][currentLength] = info;
		}
	}
}

function getInfo(identifier, infoType, indexIPP) {
	if (infoType == 0) {
		# xmapping_ion | xli | GPS hour | cycleslip2
		info = indexIPP " " $43 " " $13 " " $3 " " $20;
	}
	else if (infoType == 1) {
		# Pretty print with row and identifier (pair ID)
		info = NR "\t" identifier "\t" $43 "\t" $13 "\t" $3 "\t" $15 "\t" $20;
	}
	else if (infoType == 2) {
		txRec = $5$4;
		# id: hour | xmapping_ion | xli | raReceiver | xLatReceiver | cycleslip2
		# info = identifier " " txRec " " $43 " " $13 " " $8 " " $9 " " $20;
		# Pretty print
		info = "(Time, ID): (" identifier ", " txRec ") | (M, Li): (" $43 ", " $13 ") | Ra/Lat: (" $8 ", " $9 ") " $20;
	}
	else if (infoType == 3) {
		# 44-raReceiver | 45-latReceiver | 43-xmapping_ion | 22-d2li | 47-raSun | 48-decSun | cycleslip2
		info = $44 " " $45 " " $43 " " $21 " " $47 " " $48 " " $5$4
	}
	return info
}

# Only print the rows of the given time
function printSpecificTime(timeGPS) {
	for (j in arrayInfo[timeGPS]) {
		stringRow = arrayInfo[timeGPS][j];
		stringRow = substr(stringRow, length(stringRow)-1, length(stringRow)-1);
 		print arrayInfo[timeGPS][j];
 	}
}

function printAllUnordered() {
	for (i in arrayInfo) {
		print "-1 -1 -1 -1 " i
 	   	for (j in arrayInfo[i]) {
 	       	print arrayInfo[i][j]
 	   	}
 	}
}