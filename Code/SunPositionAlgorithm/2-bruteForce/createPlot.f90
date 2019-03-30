module createPlot
	implicit none

	! Constants
	real, parameter :: PI = atan(1.0)*4

 	contains
		subroutine traverseFile (raSun, decSun)
			real, intent(in) :: raSun, decSun
 			real :: raIPP, decIPP, mapIon, d2Li, cosX, vtec

 			do while (1 == 1)
				read (1, *, end = 240) raIPP, decIPP, mapIon, d2Li
				raIPP = toRadian(raIPP)
          		decIPP = toRadian(decIPP)
				vtec = estimateVTEC(mapIon, d2Li)
				cosx = computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
				if (vtec <= 3 .and. vtec >= -0.3) then
	         		write(34,*) cosx, vtec
	         	end if
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
			real :: solarZenithAngle

			solarZenithAngle = sin(decIPP)*sin(decSun) + cos(decIPP)*cos(decSun)*cos(raIPP - raSun)
		end function computeSolarZenithAngle

		real function toRadian(degree)
	      implicit none

	      real, intent(in) :: degree
	      real :: radians

	      radians = (degree*PI)/180
	      return
	    end function toRadian
end module createPlot