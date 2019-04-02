real function testSun (raSunIn, decSunIn)
	implicit none
	integer, intent(in) :: raSunIn, decSunIn

	real, parameter :: VTEC_UPPER_LIMIT = 3.0
	real, parameter :: VTEC_LOWER_LIMIT = -0.3
	real, parameter :: CORRELATION_THRESHOLD = -0.1

	real :: rxyPearsonCoefficient

	rxyPearsonCoefficient = traverseFile(raSunIn, decSunIn)
	return

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

		real function traverseFile (raSunIn, decSunIn)
			implicit none
			integer, intent(in) :: raSunIn, decSunIn
			real :: raIPP, decIPP, raSun, decSun, mapIon, d2Li, cosX, vtec
			real :: sumx = 0, sumy = 0, sumxy = 0, sumx2 = 0, sumy2 = 0
			real :: rxyPearson
			character(len=4) :: iString, jString
			integer :: i = 0

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
				if (vtec < VTEC_UPPER_LIMIT .and. vtec > VTEC_LOWER_LIMIT) then
					write(34,*) cosx, vtec
					if (cosx > CORRELATION_THRESHOLD) then
						call updateCorrelationParameters (cosx, vtec, sumx, sumy, sumxy, sumx2, sumy2)
					end if
				end if
				i = i + 1
			end do
			240 continue
			close(34)
			close(1)
			rxyPearson = computePearsonCoefficient(i, sumx, sumy, sumxy, sumx2, sumy2)
			return
		end function traverseFile

		subroutine updateCorrelationParameters (x, y, sumx, sumy, sumxy, sumx2, sumy2)
			implicit none
			real, intent(in) :: x, y
			real :: sumx, sumy, sumxy, sumx2, sumy2

			sumx = sumx + x
			sumy = sumy + y
			sumxy = sumxy + x*y
			sumx2 = sumx2 + x*x
			sumy2 = sumy2 + y*y

			return
		end subroutine updateCorrelationParameters

		real function computePearsonCoefficient (n, sumx, sumy, sumxy, sumx2, sumy2)
			implicit none
			integer, intent(in) :: n
			real, intent(in) :: sumx, sumy, sumxy, sumx2, sumy2
			real :: meanx, meany, numerator, denominator
			real :: rxyPearsonCoefficient

			meanx = sumx/n
			meany = sumy/n

			! numerator = sumxy - n*meanx*meany
			! denominator = sqrt(sumx2-n*meanx*meanx)*sqrt(sumy2-n*meany*meany)
			numerator = n*sumxy - sumx*sumy
			denominator = sqrt(n*sumx2-sumx*sumx)*sqrt(n*sumy2-sumy*sumy)

			rxyPearsonCoefficient = numerator/denominator

			return
		end function computePearsonCoefficient
end function testSun

