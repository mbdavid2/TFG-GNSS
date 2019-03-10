NR==1 {
	arrayInfo["test"][0] == 3;
}
{
	/a/
	txRec =  $5$4;
	if (arrayInfo[txRec][0] == "") {
			arrayInfo[txRec][0] = NR "\t" txRec "\t" $3 "\t" $15 "\t" $20;
	}
	else {
		currentLength = length(arrayInfo[txRec])
		arrayInfo[txRec][currentLength+1] = NR "\t" txRec "\t" $3 "\t" $15 "\t" $20;
	}
}

END{
	print "Total number of rows parsed: " NR "\n";
 	# printSpecificPair("11petp");
 	# printSpecificPair("6braz");
 	# printAllUnordered();
}

# Small set for debugging
NR==5000{
	print "\nTotal number of rows parsed: " NR;
 	printSpecificPair("11petp");
 	printSpecificPair("6braz");
 	# printAllUnordered();
}

# Only print the IPPs of the given receiver-transmiter pair
function printSpecificPair(pairID) {
	print "\n" "-> ID: " pairID
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