program bruteForce
	use createPlot
	implicit none

	! Variables
	integer :: status ! I/O status: 0 for success
	integer, parameter :: STEP = 60

   	open (unit = 1, file = 'outputTi.out', status = 'old', action='read', iostat=status)

   	fileopen: if (status == 0) then 
   		call checkAllAngles()
	else fileopen
		write (*, 1040) status
		1040 format (1X, 'File open failed, status = ', I6)
	end if fileopen

	close(1)

	!*******************************
 	! Procedures
	!*******************************
 	contains
	 	subroutine checkAllAngles ()
 			real :: raSun, decSun
 			integer :: ra, dec
 			character(len=4) :: iString, jString

 			do dec = -90, 90, STEP
 				if (dec /= -90 .and. dec /= 90) then
	 				do ra = -180, 180, STEP
	         			raSun = ra
	         			decSun = dec
	         			raSun = toRadian(raSun)
	         			decSun = toRadian(decSun)
	         			write(iString, '(I4.3)') ra
	         			write(jString, '(I4.3)') dec
	         			open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new') 
	         			call traverseFile(raSun, decSun) 
	         			close(34)
	  				end do
	  			end if
  			end do
	   	end subroutine checkAllAngles
end program bruteForce