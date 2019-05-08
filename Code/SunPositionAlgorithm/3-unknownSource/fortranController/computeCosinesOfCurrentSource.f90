double precision function computeCosinesOfCurrentSourceFortran (raSunIn, decSunIn)
	implicit none
	double precision, intent(in) :: raSunIn, decSunIn

	double precision :: sumy, sumy2, writeData

	double precision, parameter :: CORRELATION_THRESHOLD = -0.2

	double precision :: rxyPearsonCoefficient

	writeData = 0

	rxyPearsonCoefficient = traverseFile(raSunIn, decSunIn)
	return

	contains
		subroutine openFile ()
			implicit none
			integer :: status ! I/O status: 0 for success

			open (unit = 1, file = 'filteredByTime.out', status='old', action='read', iostat=status)

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
			! character(len=4) :: iString, jString

			! write(iString, '(F3.3)') raSunIn
			! write(jString, '(F4.3)') decSunIn
			open(34, file = 'cosineData.out', status = 'replace')
			! open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new')
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
			call openFileForWriting(raSunIn, decSunIn)

			raSun = toRadian(raSunIn)
			decSun = toRadian(decSunIn)

			do while (1 == 1)
				read (1, *, end = 240) vtec, raIPP, decIPP
				raIPP = toRadian(raIPP)
				decIPP = toRadian(decIPP)
				cosx = computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
				if (cosx > CORRELATION_THRESHOLD) then
					write(34,*) cosx, vtec
					i = i + 1
				end if
			end do
			240 continue

			close(34)
			close(1)
			! print *, "Fortran:", sumy, sumy2
			return
		end function traverseFile
end function computeCosinesOfCurrentSourceFortran

