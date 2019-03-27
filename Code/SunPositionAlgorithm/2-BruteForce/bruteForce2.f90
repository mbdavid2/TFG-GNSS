program sunTest
	implicit none

	! Variables
	integer :: status ! I/O status: 0 for success
	integer, parameter :: STEP = 45

	! Constants
	real, parameter :: ALPHA = 0.105E-17

	! Formats
	200 format (F10.8, F12.8, F12.8)
	100 format (E16.10, E18.10)

	!*******************************
 	! Main Program
	!*******************************

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
         			write(iString, '(I3.3)') i
         			write(jString, '(I3.3)') j
         			open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new') 
         			call traverseFile(raSun, decSun) 
         			close(34)
  				30  continue
  			20  continue
	   	end subroutine checkAllAngles

		subroutine traverseFile (raSun, decSun)
			real, intent(in) :: raSun, decSun
 			real :: raIPP, decIPP, mapIon, d2Li, cosX, vtec
 			integer :: i

 			i = 0
 			do while (1 == 1)
				read (1, *, end = 240) raIPP, decIPP, mapIon, d2Li
				vtec = d2Li/mapIon !estimateVTEC(mapIon, d2Li)
				cosx = computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
				if (vtec <= 3 .and. vtec >= -0.3) then
	         		write(34,*) cosx, vtec
	         	end if
				i = i + 1
		    end do
		  	240 continue ! Jumps here when read reaches EOF
		  	rewind 1
   		end subroutine traverseFile

   		real function estimateVTEC(mapIon, d2Li)
   			implicit none
   			
   			real, intent(in) :: mapIon, d2Li
   			real :: vtec

   			vtec = d2Li/mapIon

   		end function estimateVTEC

		real function computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
			implicit none

			! Parameters
			real, intent(in) :: raIPP, decIPP, raSun, decSun
			
			! Hardcoded Sun unit vector
			! real :: raSun = 212.338
			! real :: decSun = -13.059

			real, dimension(0:2) :: unitVecIPP, unitVecSun

			real :: solarZenithAngle

			! unitVecIPP(0) = cos(decIPP) * cos(raIPP)
			! unitVecIPP(1) = cos(decIPP) * sin(raIPP)
			! unitVecIPP(2) = sin(decIPP)

			! unitVecSun(0) = cos(decSun) * cos(raSun)
			! unitVecSun(1) = cos(decSun) * sin(raSun)
			! unitVecSun(2) = sin(decSun)

			! solarZenithAngle = unitVecIPP(0)*unitVecSun(0) + unitVecIPP(1)*unitVecSun(1) + unitVecIPP(2)*unitVecSun(2)

			solarZenithAngle = sin(decIPP)*sin(decSun) + cos(decIPP)*cos(decSun)*cos(raIPP - raSun)
		end function computeSolarZenithAngle

		! real function computeUnitVector(ra, dec)
		! 	implicit none

		! 	real, intent(in) :: ra, dec
		! 	real, dimension(0:2) unitVector

		! 	unitVector(0) = cos(dec) * cos(ra)
		! 	unitVector(1) = cos(dec) * sin(ra)
		! 	unitVector(2) = sin(dec)

		! end function computeUnitVector

		! real function dotProduct(vectorA, vectorB)
		! 	implicit none

		! 	real, dimension intent(in) :: vectorA, vectorB




		! end function dotProduct

end program sunTest