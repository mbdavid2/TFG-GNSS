{
	/a/
	# if ("vill" == $4) {
	
	d2li = $21;
	mappingFunc = $43;
	vtec = d2li/mappingFunc;
	# if (vtec >= -0.01 && vtec <= 0.05) {
		print $3 " " vtec
	# }
	# }
}