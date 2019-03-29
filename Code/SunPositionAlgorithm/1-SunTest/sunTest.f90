program sunTest
	implicit none

	! Variables
	integer :: status ! I/O status: 0 for success

	! Constants
	real, parameter :: ALPHA = 0.105E-17
	real, parameter :: PI = atan(1.0)*4

	! Formats
	200 format (F10.8, F12.8, F12.8)
	100 format (E16.10, E18.10)

	!*******************************
 	! Main Program
	!*******************************
	
	! Opening the file for reading, old because it already exists
   	open (unit = 1, file = 'outputTi.out', status = 'old', action='read', iostat=status)

   	! Check if the open was successful
   	! We should check the other too!!!
   	fileopen: if (status == 0) then 
   		call traverseFile()
	else fileopen
		! Open failed
		write (*, 1040) status
		1040 format (1X, 'File open failed, status = ', I6)

	end if fileopen

	! Close the file when finished
	close(1)

	!*******************************
 	! Procedures
	!*******************************
 	contains
		subroutine traverseFile ()
 			real :: raIPP, decIPP, mapIon, d2Li, raSun, decSun, cosX, vtec
 			integer :: i

 			200 format (F10.8, F12.8, F12.8)
 			100 format (I3, F10.4, F24.2)
 			123 format  (a4, a7)
 			320 format  (I3, F20.10, F20.10)
 			350 format  (F10.4, F10.4, F15.10, F15.10)

 			i = 0
 			do while (1 == 1)
				read (1, *, end = 240) raIPP, decIPP, mapIon, d2Li, raSun, decSun
				cosX = computeSolarZenithAngle(raIPP, decIPP, raSun, decSun)
				vtec = d2Li/mapIon !estimateVTEC(mapIon, d2Li)
				if (vtec < 20 .and. vtec > -0.4) then
					write (*, 350) cosX, vtec
				end if
				
				! if (vtec < 20 .and. vtec > -0.4) then
				! 	print *, i, vtec
				! end if
				i = i + 1
		    end do
		  	240 continue ! Jumps here when read reaches EOF
   		end subroutine traverseFile

   		real function estimateVTEC(mapIon, d2Li)
   			implicit none
   			
   			real, intent(in) :: mapIon, d2Li
   			real :: vtec

   			vtec = d2Li/mapIon
   			return
   		end function estimateVTEC

		real function computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
			implicit none

			! Parameters
			real :: raIPP, decIPP, raSun, decSun

			! Hardcoded Sun unit vector
			! real :: raSun = 212.338
			! real :: decSun = -13.059

			real, dimension(0:2) :: unitVecIPP, unitVecSun

			real :: solarZenithAngle

			raIPP = degreeToRadian(raIPP)
			decIPP = degreeToRadian(decIPP)
			raSun = degreeToRadian(raSun)
			decSun = degreeToRadian(decSun)

			unitVecIPP(0) = cos(decIPP) * cos(raIPP)
			unitVecIPP(1) = cos(decIPP) * sin(raIPP)
			unitVecIPP(2) = sin(decIPP)

			unitVecSun(0) = cos(decSun) * cos(raSun)
			unitVecSun(1) = cos(decSun) * sin(raSun)
			unitVecSun(2) = sin(decSun)

			! solarZenithAngle = unitVecIPP(0)*unitVecSun(0) + unitVecIPP(1)*unitVecSun(1) + unitVecIPP(2)*unitVecSun(2)

			solarZenithAngle = sin(decIPP)*sin(decSun) + cos(decIPP)*cos(decSun)*cos(raIPP - raSun)
			return
		end function computeSolarZenithAngle

		real function degreeToRadian(degree)
			real, intent(in) :: degree
			real :: radians

			radians = (degree*PI)/180
			return
		end function degreeToRadian

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