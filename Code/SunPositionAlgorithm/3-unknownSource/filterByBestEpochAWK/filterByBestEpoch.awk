# Computes the mean VTEC of all IPPs throughout an epoch
# Stores information about all epochs
# Outputs the information of the epoch with the highest VTEC mean

NR==1 {
	initializeValuesFirstRow();
}
{
    # TODO: Calculate the best VTEC within each epoch to use that
    # IPP's position in particular as a starting point for the Hill Climbing
    /a/
	epoch = $3;
    vtec = $21/$43; # 43-xmapping_ion | 21-d2li
    if (vtec > -0.5 && vtec < 0.5) {
        if (epoch != previousEpoch) {
            meanVTEC = totalEpochVTEC/n;
            if (meanVTEC > bestVTEC) {
                bestVTEC = meanVTEC;
                bestEpoch = previousEpoch;
            }
            n = 0;
            totalEpochVTEC = 0;
        }
        storeEpochInformation(epoch, vtec);
        previousEpoch = epoch;
        totalEpochVTEC += vtec;
        n++;
    }
}
END {
    printInfoSpecificEpoch(bestEpoch);
}

function initializeValuesFirstRow() {
    arrayInfo["21"][0] == 0;
    bestEpoch = $3;
    bestVTEC = 0;
    previousEpoch = $3;
    n = 0;

    # First row
    vtec = 0;
    totalEpochVTEC = 0;
}

function storeEpochInformation(epoch, vtec) {
    if (arrayInfo[epoch][0] == "") {
        info = getNecessaryParametersFromRow(vtec);
        arrayInfo[epoch][0] = info;
    }
    else {
        currentLength = length(arrayInfo[epoch])
        info = getNecessaryParametersFromRow(vtec);
        arrayInfo[epoch][currentLength] = info;
    }
}

function getNecessaryParametersFromRow(vtec) {
	# 44-raion | 45-xlation | vtec
	info = $44 " " $45 " " vtec
	return info
}

function printInfoSpecificEpoch(epoch) {
	for (i in arrayInfo[epoch]) {
        print arrayInfo[epoch][i]
 	}
}