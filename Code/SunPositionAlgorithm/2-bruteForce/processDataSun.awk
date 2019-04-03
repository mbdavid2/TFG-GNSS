{
	/a/
	timeIndex = $3;
	if (timeIndex == flareTime) {
	 	# 44-raReceiver | 45-latReceiver | 43-xmapping_ion | 22-d2li | 47-raSun | 48-decSun | cycleslip2
		info = timeIndex " " $44 " " $45 " " $43 " " $21 " " $47 " " $48 " " $5$4;
		print info;
	}
}