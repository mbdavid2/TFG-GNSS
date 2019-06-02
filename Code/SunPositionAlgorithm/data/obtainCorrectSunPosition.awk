{
	/a/
	# This works with the unfiltered file with all fields (time is now number 3)
	if ($3 == flareTime) { 
		print $47 " " $48 ; 
		exit 1;
	}
}