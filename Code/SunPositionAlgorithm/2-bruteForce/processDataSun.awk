{
	/a/
	timeIndex = $3;
	if (timeIndex == flareTime) {
		vtec = $22/$43;
	 	# 44-raReceiver | 45-latReceiver | 43-xmapping_ion | 21-d2li 
		info = $44 " " $45 " " $43 " " $21
		print info;
	}
}