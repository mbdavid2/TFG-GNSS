# Computes the mean VTEC of all IPPs throughout an epoch
# Stores information about all epochs
# Outputs the information of the epoch with the highest VTEC mean

NR==1 {
    filename = "preProcessedVTEC.out";
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
            maxVTEC[previousEpoch] = maxRaDec;
            maxCurrentVTEC = 0;
        }
        if (vtec > maxCurrentVTEC) {
            maxCurrentVTEC = vtec;
            maxRaDec = $44 " " $45 " " maxCurrentVTEC;
        }
        storeHashInformation(epoch, vtec);
        storeEpochInformation(epoch, vtec);
        previousEpoch = epoch;
        totalEpochVTEC += vtec;
        n++;
    }
}
END {
    print maxVTEC[bestEpoch] > filename;
    printInfoSpecificEpoch(bestEpoch);
    
    # printHashInformation(bestEpoch);
}

function initializeValuesFirstRow() {
    arrayInfo["21"][0] = 0;
    hashInfo["21"][0] = 0;
    maxVTEC["21"] = 0;
    maxCurrentVTEC = 0;
    maxRaDec = "0 0"
    bestEpoch = $3;
    bestVTEC = 0;
    previousEpoch = $3;
    n = 0;

    # First row
    vtec = 0;
    totalEpochVTEC = 0;
}

function storeHashInformation(epoch, vtec) {
    hashID = hashFunction($44, $45);
    if (hashInfo[epoch][hashID] == "") {
        hashInfo[epoch][hashID] = vtec;     
    }
    else {
        hashInfo[epoch][hashID] += vtec;   
    }
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

function storeMaxVTECCurrent(epoch, maxRaDec) {
    
}

function getNecessaryParametersFromRow(vtec) {
	# 44-raion | 45-xlation | vtec
	info = $44 " " $45 " " vtec 
	return info;
}

function printInfoSpecificEpoch(epoch) {
	for (i in arrayInfo[epoch]) {
        # if (i == 0) print arrayInfo[epoch][i] > filename
        # else 
        print arrayInfo[epoch][i] >> filename
 	}
}

function printHashInformation(epoch) {
    max = 0
    maxID = 0
	for (i in hashInfo[epoch]) {
        # print "Hash ID: " i " Total VTEC: " hashInfo[epoch][i]
        if (hashInfo[epoch][i] > max) {
            max = hashInfo[epoch][i]
            maxID = i
        }
 	}
    print "Hash ID: " i " Total VTEC: " hashInfo[epoch][i]
}

function hashFunction(ra, dec) {
    basic = ra/dec;
    basic = basic;
    basic = basic*1000
    basicInt = int(basic)
    basicInt = int(basicInt/100)
    oldRange = (20-(-20))
    newRange = (10 - 0);
    return basicInt;
}