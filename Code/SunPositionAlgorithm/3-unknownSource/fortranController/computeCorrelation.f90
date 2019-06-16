double precision function computeCorrelationFortran (raSunIn, decSunIn, numRows)
	use omp_lib, only: OMP_Get_num_threads;
	implicit none

	double precision, intent(in) :: raSunIn, decSunIn

	double precision :: sumy, sumy2, writeData

	double precision, parameter :: CORRELATION_THRESHOLD = -0.2

	double precision :: rxyPearsonCoefficient

	integer, intent(in) :: numRows

	! print *, "----------- computeCorrelationFortran -----------"
	! ! This will always print "1"
	! print *,OMP_Get_num_threads()

	! ! This will print the actual number of threads
	! CALL OMP_SET_NUM_THREADS(3)
	! !$omp parallel
	! print *,OMP_Get_num_threads()
	!!$omp end parallel


	writeData = 0

	rxyPearsonCoefficient = traverseFile(raSunIn, decSunIn)
	return

	contains
		subroutine openFile ()
			implicit none
			integer :: status ! I/O status: 0 for success

			open (unit = 1, file = 'cosineDataFitted.out', status='old', action='read', iostat=status)

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

			!!$OMP PARALLEL DO PRIVATE(cosx, vtec) REDUCTION(-: sumx, sumy, sumxy, sumx2, sumy2)
			do i = 0, numRows
				! write(*,*) "Currently in thread with ID = ",omp_get_thread_num()
				read (1, *, end = 240) cosx, vtec
				call updateCorrelationParameters (cosx, vtec, sumx, sumy, sumxy, sumx2, sumy2)
				! i = i + 1
			end do
			!!$OMP END PARALLEL DO
			240 continue

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
end function computeCorrelationFortran

