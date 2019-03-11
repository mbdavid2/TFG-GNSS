NR==1 {
	arrayInfo["test"][0] == 3;
	printType = 0;
	# (Sampling rate: 30s, 0.5m, 1/120 = 0.83333h);
	hardcodedTime = 1/120; 
}
{
	/a/
	txRec =  $5$4;
	info = getInfo(txRec, printType)
	if (arrayInfo[txRec][0] == "") {
			arrayInfo[txRec][0] = info;
	}
	else {
		currentLength = length(arrayInfo[txRec])
		arrayInfo[txRec][currentLength+1] = info;
	}
}

END{
	# print "Total number of rows parsed: " NR "\n";
 	# printSpecificPair("11petp");
 	# printSpecificPair("6braz");
 	# printAllUnordered();
}

# Small set for debugging
NR==10000{
	# print "\nTotal number of rows parsed: " NR;
 	printSpecificPair("11petp");
 	# printSpecificPair("6braz");
 	# printAllUnordered();
}

function getInfo(pairID, printType) {
	if (printType == 0) {
		# Only necessary data
		# xmapping_ion | xli | GPS hour | narch2 | cycleslip2
		#info = $43 "\t" $13 "\t" $3 "\t" $15 "\t" $20;

		# xmapping_ion | xli | GPS hour | cycleslip2
		info = $43 " " $13 " " $3 " " $20;
	}
	else if (printType == 1) {
		# Pretty print with row and pairID
		info = NR "\t" pairID "\t" $43 "\t" $13 "\t" $3 "\t" $15 "\t" $20;
	}
	return info
}

# Only print the IPPs of the given receiver-transmiter pair
function printSpecificPair(pairID) {
	# print "\n" "-> ID: " pairID
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

function printAllUnordered() {
	for (i in arrayInfo)
 	   	for (j in arrayInfo[i])
 	       	print arrayInfo[i][j]
}