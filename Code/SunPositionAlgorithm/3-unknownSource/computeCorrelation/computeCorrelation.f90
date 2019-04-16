double precision function mainFortran (raSunIn, decSunIn, sumy, sumy2, writeData)
	implicit none
	double precision, intent(in) :: raSunIn, decSunIn, sumy, sumy2, writeData

	double precision, parameter :: CORRELATION_THRESHOLD = -0.5

	double precision :: rxyPearsonCoefficient

	rxyPearsonCoefficient = traverseFile(raSunIn, decSunIn)
	return

	contains
		subroutine openFile ()
			implicit none
			integer :: status ! I/O status: 0 for success

			open (unit = 1, file = 'spikeData.out', status='old', action='read', iostat=status)

		   	if (status /= 0) then 
				write (*, 1040) status
				1040 format (1X, 'File open failed, status = ', I6)
			end if
		end subroutine openFile

		double precision function computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
			implicit none
			double precision, intent(in) :: raIPP, decIPP, raSun, decSun
			double precision :: solarZenithAngle

			solarZenithAngle = sin(decIPP)*sin(decSun) + cos(decIPP)*cos(decSun)*cos(raIPP - raSun)
			return
		end function computeSolarZenithAngle

		double precision function toRadian (degree)
		  implicit none
		  double precision, parameter :: PI = atan(1.0)*4
		  double precision, intent(in) :: degree
		  double precision :: radians

		  radians = (degree*PI)/180
		  return
		end function toRadian

		subroutine openFileForWriting (raSunIn, decSunIn)
			implicit none
			double precision, intent(in) :: raSunIn, decSunIn
			character(len=4) :: iString, jString

			write(iString, '(F3.3)') raSunIn
			write(jString, '(F4.3)') decSunIn

			open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new')
		end subroutine openFileForWriting

		double precision function traverseFile (raSunIn, decSunIn)
			implicit none
			double precision, intent(in) :: raSunIn, decSunIn
			double precision :: raIPP, decIPP, raSun, decSun, cosX, vtec
			double precision :: sumx = 0, sumxy = 0, sumx2 = 0, sumy = 0, sumy2 = 0
			double precision :: rxyPearson
			
			integer :: i = 0

			sumx = 0
			sumy = 0
			sumxy = 0
			sumx2 = 0
			sumy2 = 0
			i = 0
			
			call openFile()
			
			if (writeData == 1) then
				call openFileForWriting(raSunIn, decSunIn)
			end if

			raSun = toRadian(raSunIn)
			decSun = toRadian(decSunIn)

			do while (1 == 1)
				read (1, *, end = 240) vtec, raIPP, decIPP
				raIPP = toRadian(raIPP)
				decIPP = toRadian(decIPP)
				cosx = computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
				if (cosx > CORRELATION_THRESHOLD) then
					if (writeData == 1) then
						write(34,*) cosx, vtec
					end if
					call updateCorrelationParameters (cosx, vtec, sumx, sumy, sumxy, sumx2, sumy2)
					i = i + 1
				end if
			end do
			240 continue

			if (writeData == 1) then
				close(34)
			end if
			close(1)
			! print *, "Fortran:", sumy, sumy2
			rxyPearson = computePearsonCoefficient(i, sumx, sumy, sumxy, sumx2, sumy2)
			return
		end function traverseFile

		subroutine updateCorrelationParameters (x, y, sumx, sumy, sumxy, sumx2, sumy2)
			implicit none
			double precision, intent(in) :: x, y
			double precision :: sumy, sumy2, sumxy, sumx2, sumx

			sumx = sumx + x
			sumy = sumy + y
			sumxy = sumxy + x*y
			sumx2 = sumx2 + x*x
			sumy2 = sumy2 + y*y

			return
		end subroutine updateCorrelationParameters

		double precision function computePearsonCoefficient (n, sumx, sumy, sumxy, sumx2, sumy2)
			implicit none
			integer, intent(in) :: n
			double precision, intent(in) :: sumx, sumy, sumxy, sumx2, sumy2 
			double precision :: meanx, meany, numerator, denominator
			double precision :: rxyPearsonCoefficient
			! meanx = sumx/n
			! meany = sumy/n

			! numerator = sumxy - n*meanx*meany
			! denominator = sqrt(sumx2-n*meanx*meanx)*sqrt(sumy2-n*meany*meany)
			numerator = n*sumxy - sumx*sumy
			denominator = sqrt(n*sumx2-sumx*sumx)*sqrt(n*sumy2-sumy*sumy)

			rxyPearsonCoefficient = numerator/denominator
			return
		end function computePearsonCoefficient
end function mainFortran

