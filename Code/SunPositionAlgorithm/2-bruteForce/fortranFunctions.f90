subroutine test (raSunIn, decSunIn)
	implicit none
	integer, intent(in) :: raSunIn, decSunIn

	call traverseFile(raSunIn, decSunIn)

	contains
		subroutine openFile ()
			implicit none
			integer :: status ! I/O status: 0 for success

			open (unit = 1, file = 'outputTi.out', status = 'old', action='read', iostat=status)

		   	if (status /= 0) then 
				write (*, 1040) status
				1040 format (1X, 'File open failed, status = ', I6)
			end if
		end subroutine openFile

		real function estimateVTEC (mapIon, d2Li)
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

		real function toRadian (degree)
		  implicit none
		  real, parameter :: PI = atan(1.0)*4
		  real, intent(in) :: degree
		  real :: radians

		  radians = (degree*PI)/180
		  return
		end function toRadian

		subroutine traverseFile (raSunIn, decSunIn)
			implicit none
			integer, intent(in) :: raSunIn, decSunIn
			real :: raIPP, decIPP, raSun, decSun, mapIon, d2Li, cosX, vtec
			character(len=4) :: iString, jString
			raSun = raSunIn
			decSun = decSunIn
			raSun = toRadian(raSun)
			decSun = toRadian(decSun)
			write(iString, '(I3.3)') raSunIn
			write(jString, '(I4.3)') decSunIn

			call openFile()
			open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new') 
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
			240 continue
			close(34)
			rewind 1
			return
		end subroutine traverseFile
end subroutine test

