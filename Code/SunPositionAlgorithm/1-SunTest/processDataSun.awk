NR==1 {
	arrayInfo["test"][0] == 3;
	# (Sampling rate: 30s, 0.5m, 1/120 = 0.83333h);
	hardcodedTime = 1/120; 
	typeOfGrouping = 0;
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

function groupByPair() {
	pairID = $5$4;
	infoType = 3;
	if (arrayInfo[pairID][0] == "") {
		info = getInfo(pairID, infoType, 0);
		arrayInfo[pairID][0] = info;
	}
	else {
		currentLength = length(arrayInfo[pairID])
		info = getInfo(pairID, infoType, currentLength);
		arrayInfo[pairID][currentLength] = info;
	}
}

function groupByTime() {
	infoType = 3;
	timeIndex = $3;
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
		# 44 xra 45 xlat 47 rasun 48decsun 21 d2li
		# xmapping_ion | d2li | raReceiver | latReceiver | raSun | decSun | cycleslip2
		# info = $44 " " $45 " " $47 " " $48 " " $43 " " $21 Sun info too
		info = $44 " " $45 " " $43 " " $21
	}
	return info
}

function mapPairIDToInt(pairID) {
	return 2345
}

# Only print the rows of the given receiver-transmiter pair (IPP)
function printSpecificPair(pairID) {
	intPairID = mapPairIDToInt(pairID);
	print "-1" intPairID
	for (j in arrayInfo[pairID]) {
		stringRow = arrayInfo[pairID][j];
		stringRow = substr(stringRow, length(stringRow)-1, length(stringRow)-1);
		# why does substring return it with a tab before?¿?¿?
		if (stringRow == "\tT") { 
			print "-------- Cycle slip ---------"
		}
 		print arrayInfo[pairID][j];
 	}
}

# Only print the rows of the given time
function printSpecificTime(timeGPS) {
	for (j in arrayInfo[timeGPS]) {
		stringRow = arrayInfo[timeGPS][j];
		stringRow = substr(stringRow, length(stringRow)-1, length(stringRow)-1);
		# why does substring return it with a tab before?¿?¿?
		if (stringRow == "\tT") { 
			print "-------- Cycle slip ---------"
		}
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