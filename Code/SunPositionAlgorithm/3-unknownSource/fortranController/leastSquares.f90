double precision function leastSquaresFortran(inputFileName, numRows)
	implicit none
	character(len=20), intent(in) :: inputFileName
	double precision :: rxyPearsonCoefficient
	integer, intent(in) :: numRows

	call openFile(inputFileName)
	call leastSquares() 
	! TODO: we should pass the real number of rows

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

		subroutine leastSquares()
			implicit none
			double precision, dimension (0:numRows) :: matrixVTEC
			double precision, dimension (0:numRows, 0:3) :: matrixIPP
			double precision, dimension (0:3) :: X
			integer :: vtecSize, i

			call storeMatrixData(matrixVTEC, matrixIPP)

			vtecSize = size(matrixVTEC)
			do i = 0, vtecSize-1
				print *, matrixVTEC(i)
				print *, matrixIPP(i,0), matrixIPP(i,1), matrixIPP(i,2), matrixIPP(i,3)
			end do

			! call computeMatrixComputations(X, matrixIPP, matrixVTEC)

		end subroutine leastSquares

		subroutine computeMatrixComputations(X, A, Y)
			implicit none
			double precision, dimension (0:numRows), intent(in) :: Y, X
			double precision, dimension (0:numRows, 0:3), intent(in) :: A
			double precision, dimension (0:3, 0:numRows) :: transposedA, innerMat

			transposedA = transpose(A)
			innerMat = matmul(transposedA, A)
		end subroutine computeMatrixComputations

		subroutine storeMatrixData(matrixVTEC, matrixIPP)
			implicit none
			double precision, dimension (0:numRows), intent(out) :: matrixVTEC
			double precision, dimension (0:numRows, 0:3), intent(out) :: matrixIPP
			double precision :: vtec, raIPP, decIPP
			double precision :: xIPP, yIPP, zIPP
			
			integer :: i
			i = 0

			do while (1 == 1)
				read (1, *, end = 240) vtec, raIPP, decIPP
				
				call computeComponentsIPP(raIPP, decIPP, xIPP, yIPP, zIPP)

				matrixVTEC(i) = vtec
				matrixIPP(i, 0) = xIPP
				matrixIPP(i, 1) = yIPP
				matrixIPP(i, 2) = zIPP
				matrixIPP(i, 3) = 1

				i = i + 1
			end do
			240 continue
			close(1)
		end subroutine storeMatrixData

		subroutine computeComponentsIPP(ra, dec, xIPP, yIPP, zIPP)
			implicit none
			double precision, intent(in) :: ra, dec
			double precision :: raRad, decRad
			double precision, intent(out) :: xIPP, yIPP, zIPP

			raRad = toRadian(ra)
			decRad = toRadian(dec)

			xIPP = cos(decRad)*cos(raRad)
			yIPP = cos(decRad)*sin(raRad)
			zIPP = sin(decRad)

			return
		end subroutine computeComponentsIPP

		double precision function toRadian (degree)
		  implicit none
		  double precision, parameter :: PI = atan(1.0)*4
		  double precision, intent(in) :: degree
		  double precision :: radians

		  radians = (degree*PI)/180
		  return
		end function toRadian
end function leastSquaresFortran

