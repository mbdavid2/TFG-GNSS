program sunTestMain
	use createPlot
	implicit none

	! Variables
	integer :: status ! I/O status: 0 for success

	real:: raSun, decSun

	! Opening the file for reading, old because it already exists
   	open (unit = 1, file = 'outputTi.out', status = 'old', action = 'read', iostat = status)

   	! Check if the open was successful
   	if (status == 0) then 
   		! For this particular case all IPPs have the same Sun location registered
		! Hardoced here so we don't have to read it and process it every time
		raSun = toRadian(212.338)
		decSun = toRadian(-13.060)
   		call traverseFile(raSun, decSun)
	else
		write (*, 104) status
		104 format (1X, 'File open failed, status = ', I6)
	end if

	! Close the file when finished
	close(1)
end program sunTestMain