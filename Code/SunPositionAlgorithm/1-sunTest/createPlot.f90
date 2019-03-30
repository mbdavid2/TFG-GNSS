module createPlot
	implicit none

	! Constants
	real, parameter :: PI = atan(1.0)*4

 	contains
		subroutine traverseFile ()
			implicit none
 			real :: raIPP, decIPP, raSun, decSun, mapIon, d2Li, cosX, vtec

 			! For this particular case all IPPs have the same Sun location registered
 			! Hardoced here so we don't have to read it and process it every time
 			raSun = toRadian(212.338)
			decSun = toRadian(-13.060)

 			350 format  (F10.4, F10.4, F15.10, F15.10)
 			
 			do while (1 == 1)
				read (1, *, end = 240) raIPP, decIPP, mapIon, d2Li
				raIPP = toRadian(raIPP)
				decIPP = toRadian(decIPP)
				cosX = computeSolarZenithAngle(raIPP, decIPP, raSun, decSun)
				vtec = estimateVTEC(mapIon, d2Li)
				if (vtec < 20 .and. vtec > -0.4) then
					write (*, 350) cosX, vtec
				end if
		    end do
		  	240 continue
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

			real, intent(in) :: raIPP, decIPP, raSun, decSun
			real :: solarZenithAngle
			
			solarZenithAngle = sin(decIPP)*sin(decSun) + cos(decIPP)*cos(decSun)*cos(raIPP - raSun)
			return
		end function computeSolarZenithAngle

		real function toRadian(degree)
			implicit none

			real, intent(in) :: degree
			real :: radians

			radians = (degree*PI)/180
			return
		end function toRadian
end module createPlot