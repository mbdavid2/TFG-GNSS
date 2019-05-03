double precision function leastSquaresFortran(inputFileName)
	implicit none
	character(len=20), intent(in) :: inputFileName

	double precision :: rxyPearsonCoefficient

	call openFile(inputFileName)

	rxyPearsonCoefficient = 23232
	return

	contains
		subroutine openFile (inputFileName)
			implicit none
			character(len = 20), intent(in) :: inputFileName
			integer :: status ! I/O status: 0 for success

			open (unit = 1, file = inputFileName, status='old', action='read', iostat=status)

		   	if (status /= 0) then 
				write (*, 1040) status
				1040 format (1X, 'File open failed, status = ', I6)
			end if
		end subroutine openFile

		double precision function toRadian (degree)
		  implicit none
		  double precision, parameter :: PI = atan(1.0)*4
		  double precision, intent(in) :: degree
		  double precision :: radians

		  radians = (degree*PI)/180
		  return
		end function toRadian

		subroutine computeComponentsIPP(ra, dec, xIPP, yIPP, zIPP)
			implicit none
			double precision, intent(in) :: ra, dec
			double precision, intent(out) :: xIPP, yIPP, zIPP

			xIPP = cos(dec)*cos(ra)
			yIPP = cos(dec)*sin(ra)
			zIPP = sin(dec)

			return
		end subroutine computeComponentsIPP

		subroutine leastSquares()
			implicit none

			double precision :: vtec, raIPP, decIPP
			double precision :: xIPP, yIPP, zIPP

			do while (1 == 1)
				read (1, *, end = 240) vtec, raIPP, decIPP
				raIPP = toRadian(raIPP)
				decIPP = toRadian(decIPP)
				call computeComponentsIPP(raIPP, decIPP, xIPP, yIPP, zIPP)
				write (*, *) xIPP, yIPP, zIPP
			end do
			240 continue
			close(1)

		end subroutine leastSquares
end function leastSquaresFortran

