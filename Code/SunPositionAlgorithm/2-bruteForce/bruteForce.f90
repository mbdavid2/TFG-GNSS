program bruteForce
	use createPlot
	implicit none

	! Variables
	integer :: status ! I/O status: 0 for success
	integer, parameter :: STEP = 30

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
 			integer :: i, j
 			character(len=4) :: iString, jString
 			! character(len=20)

 			do 20 i = 0, 360, STEP
         		! write(*,*) 'i =', i
         		do 30 j = 0, 180, STEP
         			! write(*,*) '	j =', j
         			raSun = i
         			decSun = j
         			raSun = toRadian(raSun)
         			decSun = toRadian(decSun)
         			write(iString, '(I3.3)') i
         			write(jString, '(I3.3)') j
         			open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new') 
         			call traverseFile(raSun, decSun) 
         			close(34)
  				30  continue
  			20  continue
	   	end subroutine checkAllAngles
end program bruteForce