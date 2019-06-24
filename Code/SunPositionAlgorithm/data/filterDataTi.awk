BEGIN {
	upperLimitVTEC = 0.7;
	lowerLimitVTEC = -0.7;
	discardSunHemisphere = 1;
	PI = 4*atan2(1,1);
	COSINE_THRESHOLD = -0.2;
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
	# lowerValidRa = ((raIPP - 90) ? raIPP - 90 : 0);
	# upperValidRa = ((raIPP + 90) ? raIPP + 90 : 360);

	# return !(raSun >= lowerValidRa && raSun <= upperValidRa)
	return unitVectorsCosine(raSun, decSun, raIPP, decIPP) <= COSINE_THRESHOLD
}

function printData() {
	vtec = $21/$43;
	if ($20 == "F") {
		if (vtec >= lowerLimitVTEC && vtec <= upperLimitVTEC) { # Activar para ls, desactivar para decrease range
			print $3 " " vtec " " $44 " " $45;	
		}
	}
}

function abs(x){
	return ((x < 0.0) ? -x : x)
}

function toRadian(degree) {
	return (degree*PI)/180;
}

function unitVectorsCosine(raSource, decSource, raIPP, decIPP) {
	raSource = toRadian(raSource)
	decSource = toRadian(decSource)
	raIPP = toRadian(raIPP)
	decIPP = toRadian(decIPP)
	return (sin(decIPP)*sin(decSource) + cos(decIPP)*cos(decSource)*cos(raIPP - raSource));
}