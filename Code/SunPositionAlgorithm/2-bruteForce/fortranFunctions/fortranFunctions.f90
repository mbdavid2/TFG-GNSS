double precision function testSun (raSunIn, decSunIn)
	implicit none
	integer, intent(in) :: raSunIn, decSunIn

	double precision, parameter :: VTEC_UPPER_LIMIT = 3.0
	double precision, parameter :: VTEC_LOWER_LIMIT = -0.3
	double precision, parameter :: CORRELATION_THRESHOLD = -0.1

	double precision :: rxyPearsonCoefficient

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

		double precision function estimateVTEC (mapIon, d2Li)
			implicit none
			double precision, intent(in) :: mapIon, d2Li
			double precision :: vtec

			vtec = d2Li/mapIon
			return
		end function estimateVTEC

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

		double precision function traverseFile (raSunIn, decSunIn)
			implicit none
			integer, intent(in) :: raSunIn, decSunIn
			double precision :: raIPP, decIPP, raSun, decSun, mapIon, d2Li, cosX, vtec
			double precision :: sumx = 0, sumy = 0, sumxy = 0, sumx2 = 0, sumy2 = 0
			double precision :: rxyPearson
			character(len=4) :: iString, jString
			integer :: i = 0

			sumx = 0
			sumy = 0
			sumxy = 0
			sumx2 = 0
			sumy2 = 0
			i = 0

			raSun = raSunIn
			decSun = decSunIn
			raSun = toRadian(raSun)
			decSun = toRadian(decSun)
			write(iString, '(I3.3)') raSunIn
			write(jString, '(I4.3)') decSunIn
			call openFile()
			open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new') 
			write(34,*) "cosx vtec"
			do while (1 == 1)
				read (1, *, end = 240) raIPP, decIPP, mapIon, d2Li
				raIPP = toRadian(raIPP)
				decIPP = toRadian(decIPP)
				vtec = estimateVTEC(mapIon, d2Li)
				cosx = computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
				if (vtec < VTEC_UPPER_LIMIT .and. vtec > VTEC_LOWER_LIMIT) then
					if (cosx > CORRELATION_THRESHOLD) then
						write(34,*) cosx, vtec
						call updateCorrelationParameters (cosx, vtec, sumx, sumy, sumxy, sumx2, sumy2)
						i = i + 1
					end if
				end if	
			end do
			240 continue
			close(34)
			close(1)
			rxyPearson = computePearsonCoefficient(i, sumx, sumy, sumxy, sumx2, sumy2)
			return
		end function traverseFile

		subroutine updateCorrelationParameters (x, y, sumx, sumy, sumxy, sumx2, sumy2)
			implicit none
			double precision, intent(in) :: x, y
			double precision :: sumx, sumy, sumxy, sumx2, sumy2

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


		!############ Se supone que es la version de dos pasadas del calculo de la correlacion pero hay mucha cosas mal que hay que arreglar mirando como esta hecho arriuba
		! double precision function traverseFile2 (raSunIn, decSunIn)
		! 	implicit none
		! 	integer, intent(in) :: raSunIn, decSunIn
		! 	double precision :: raIPP, decIPP, raSun, decSun, mapIon, d2Li, cosX, vtec
		! 	double precision :: sumx = 0, sumy = 0, meanx = 0, meany = 0, sumxy = 0, sumx2 = 0, sumy2 = 0
		! 	double precision :: rxyPearson
		! 	character(len=4) :: iString, jString
		! 	integer :: i = 0

		! 	raSun = raSunIn
		! 	decSun = decSunIn
		! 	raSun = toRadian(raSun)
		! 	decSun = toRadian(decSun)
		! 	write(iString, '(I3.3)') raSunIn
		! 	write(jString, '(I4.3)') decSunIn

		! 	call openFile()
		! 	open(34, file = 'results/ra' // trim(iString) // '_dec' // trim(jString), status = 'new') 
		! 	write(34,*) "cosx vtec"
		! 	do while (1 == 1)
		! 		read (1, *, end = 240) raIPP, decIPP, mapIon, d2Li
		! 		raIPP = toRadian(raIPP)
		! 		decIPP = toRadian(decIPP)
		! 		vtec = estimateVTEC(mapIon, d2Li)
		! 		cosx = computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
		! 		if (vtec < VTEC_UPPER_LIMIT .and. vtec > VTEC_LOWER_LIMIT) then
		! 			if (cosx > CORRELATION_THRESHOLD) then
		! 				write(34,*) cosx, vtec
		! 				call sumParameters (cosx, vtec, sumx, sumy)
		! 			end if
		! 		end if
		! 		i = i + 1
		! 	end do
		! 	240 continue
		! 	close(34)
		! 	rewind 1
		! 	meanx = sumx
		! 	print *, meanx
		! 	meany = sumy
		! 	print *, meany
		! 	do while (1 == 1)
		! 		read (1, *, end = 250) raIPP, decIPP, mapIon, d2Li
		! 		raIPP = toRadian(raIPP)
		! 		decIPP = toRadian(decIPP)
		! 		vtec = estimateVTEC(mapIon, d2Li)
		! 		cosx = computeSolarZenithAngle (raIPP, decIPP, raSun, decSun)
		! 		if (vtec < VTEC_UPPER_LIMIT .and. vtec > VTEC_LOWER_LIMIT) then
		! 			if (cosx > CORRELATION_THRESHOLD) then
		! 				call updateCorrelationParameters2 (cosx, vtec, meanx, meany, sumxy, sumx2, sumy2)
		! 			end if
		! 		end if
		! 		i = i + 1
		! 	end do
		! 	250 continue
		! 	close(1)
		! 	rxyPearson = computePearsonCoefficient2(i, sumx, sumy, sumxy, sumx2, sumy2)
		! 	return
		! end function traverseFile2

		! subroutine sumParameters (x, y, sumx, sumy)
		! 	implicit none
		! 	double precision, intent(in) :: x, y
		! 	double precision :: sumx, sumy

		! 	sumx = sumx + x
		! 	sumy = sumy + y

		! 	return
		! end subroutine sumParameters

		! subroutine updateCorrelationParameters2 (x, y, meanx, meany, sumxy, sumx2, sumy2)
		! 	implicit none
		! 	double precision, intent(in) :: x, y
		! 	double precision :: meanx, meany, sumxy, sumx2, sumy2

		! 	sumxy = (x-meanx)*(y-meany)
		! 	sumx2 = (x-meanx)*(x-meanx)
		! 	sumy2 = (y-meany)*(y-meany)

		! 	return
		! end subroutine updateCorrelationParameters2

		! double precision function computePearsonCoefficient2 (n, sumx, sumy, sumxy, sumx2, sumy2)
		! 	implicit none
		! 	integer, intent(in) :: n
		! 	double precision, intent(in) :: sumx, sumy, sumxy, sumx2, sumy2 
		! 	double precision :: meanx, meany, numerator, denominator
		! 	double precision :: rxyPearsonCoefficient

		! 	meanx = sumx/n
		! 	meany = sumy/n

		! 	! numerator = sumxy - n*meanx*meany
		! 	! denominator = sqrt(sumx2-n*meanx*meanx)*sqrt(sumy2-n*meany*meany)
		! 	numerator = sumxy
		! 	denominator = sqrt(sumx2)*sqrt(sumy2)

		! 	rxyPearsonCoefficient = numerator/denominator

		! 	return
		! end function computePearsonCoefficient2

		
end function testSun

