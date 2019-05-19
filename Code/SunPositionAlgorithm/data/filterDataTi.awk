BEGIN {
	upperLimitVTEC = 10;
	lowerLimitVTEC = -10;
	discardSunHemisphere = 0
}
{
	/a/
	# 3 - time | 4 - recId | 5 - txId | 21 - d2li | 43 - xmappingion | 44 -xraion | 45 - xlation |||||| 47 - rasun | 48 - decsun
	if (discardSunHemisphere == 0 || checkValidIPP($47, $48, $44, $45)) {
		printData();
	}	
}

function checkValidIPP(raSun, decSun, raIPP, decIPP) {
	# Valid ra: If the Sun is not in the range [raIPP + 90º, raIPP - 90º].
	lowerValidRa = ((raIPP - 90) ? raIPP - 90 : 0);
	upperValidRa = ((raIPP + 90) ? raIPP + 90 : 360);

	return !(raSun >= lowerValidRa && raSun <= upperValidRa)
}

function printData() {
	vtec = $21/$43;
	if (vtec >= lowerLimitVTEC && vtec <= upperLimitVTEC) { # Activar para ls, desactivar para decrease range
		print $3 " " vtec " " $44 " " $45;	
	}
}

function abs(x){
	return ((x < 0.0) ? -x : x)
}