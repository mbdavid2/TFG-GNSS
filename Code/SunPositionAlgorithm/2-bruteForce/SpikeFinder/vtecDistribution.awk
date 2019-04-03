{
	/a/
	d2li = $21;
	mappingFunc = $43;
	vtec = d2li/mappingFunc;
	if (vtec > -0.5 && vtec < 0.5) {
		# 3-time | vtec | 44-raReceiver | 45-latReceiver
		info = $3 " " vtec " " $44 " " $45
		print info
	}
}