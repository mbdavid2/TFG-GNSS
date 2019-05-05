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
			double precision, dimension (0:3) :: solution
			integer :: vtecSize, i

			call storeMatrixData(matrixVTEC, matrixIPP)

			! vtecSize = size(matrixVTEC)
			! do i = 0, vtecSize-1
			! 	print *, matrixVTEC(i)
			! 	print *, matrixIPP(i,0), matrixIPP(i,1), matrixIPP(i,2), matrixIPP(i,3)
			! end do

			call matrixComputations(solution, matrixIPP, matrixVTEC)
			print *, "Results:"
			print *, solution(0), solution(1), solution(2), solution(3)
			call obtainSourceLocation(solution)

		end subroutine leastSquares

		subroutine matrixComputations(solution, A, Y)
			implicit none
			double precision, dimension (0:3), intent(out) :: solution
			double precision, dimension (0:numRows), intent(in) :: Y
			double precision, dimension (0:numRows, 0:3), intent(in) :: A
			double precision, dimension (0:3, 0:numRows) :: transposedA, innerMat
			double precision, dimension (0:numRows, 0:3) :: invMult

			transposedA = transpose(A)
			! invMult = inv(matmul(transposedA, A))
			
			solution = matmul(matmul(inv(matmul(transposedA, A)), transposedA), y) ! esto dejarlo mas bonito???
		end subroutine matrixComputations

		subroutine obtainSourceLocation(solution)
			double precision, dimension (0:3), intent(in) :: solution
			double precision :: a, b, g, mod
			double precision :: X, Y, Z, ra, dec

			a = solution(0)
			b = solution(1)
			g = solution(2)

			mod = sqrt(a*a + b*b + g*g)

			X = a/mod
			Y = b/mod
			Z = g/mod

			dec = asin(Z)
			ra = asin(Y/cos(dec))
			print *, "Ra, Dec: ", toDegree(ra), toDegree(dec)
			ra = acos(X/cos(dec))
			print *, "Ra2, Dec: ", toDegree(ra), toDegree(dec)
		end subroutine obtainSourceLocation

		subroutine storeMatrixData(matrixVTEC, matrixIPP)
			implicit none
			double precision, dimension (0:numRows), intent(out) :: matrixVTEC
			double precision, dimension (0:numRows, 0:3), intent(out) :: matrixIPP
			double precision :: vtec, raIPP, decIPP
			double precision :: xIPP, yIPP, zIPP
			
			integer :: i

			do i = 0, numRows
				read (1, *, end = 240) vtec, raIPP, decIPP
				
				call computeComponentsIPP(raIPP, decIPP, xIPP, yIPP, zIPP)

				matrixVTEC(i) = vtec
				matrixIPP(i, 0) = xIPP
				matrixIPP(i, 1) = yIPP
				matrixIPP(i, 2) = zIPP
				matrixIPP(i, 3) = 1
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

		double precision function toRadian(degree)
		  implicit none
		  double precision, parameter :: PI = atan(1.0)*4
		  double precision, intent(in) :: degree
		  double precision :: radians

		  radians = (degree*PI)/180
		  return
		end function toRadian

		double precision function toDegree(radians)
		  implicit none
		  double precision, parameter :: PI = atan(1.0)*4
		  double precision, intent(in) :: radians
		  double precision :: degree

		  degree = (radians*180/PI)
		  return
		end function toDegree

		! subroutine inverse(A, invA)
		! 	implicit none

		! 	external DGETRI

		! 	double precision, dimension (0:numRows, 0:3), intent(in) :: A
		! 	double precision, dimension (0:numRows, 0:3), intent(out) :: invA

		! 	call DGETRI(3, invA, 3, ipiv, work, n, info)


		! end subroutine

		! Returns the inverse of a matrix calculated by finding the LU
		! decomposition.  Depends on LAPACK.
		function inv(A) result(Ainv)
			double precision, dimension(:,:), intent(in) :: A
			double precision, dimension(size(A,1),size(A,2)) :: Ainv

			double precision, dimension(size(A,1)) :: work  ! work array for LAPACK
			integer, dimension(size(A,1)) :: ipiv   ! pivot indices
			integer :: n, info

			! External procedures defined in LAPACK
			external DGETRF
			external DGETRI

			! Store A in Ainv to prevent it from being overwritten by LAPACK
			Ainv = A
			n = size(A,1)

			! DGETRF computes an LU factorization of a general M-by-N matrix A
			! using partial pivoting with row interchanges.
			call DGETRF(n, n, Ainv, n, ipiv, info)

			if (info /= 0) then
				stop 'Matrix is numerically singular!'
			end if

			! DGETRI computes the inverse of a matrix using the LU factorization
			! computed by DGETRF.
			call DGETRI(n, Ainv, n, ipiv, work, n, info)

			if (info /= 0) then
				stop 'Matrix inversion failed!'
			end if
		end function inv
end function leastSquaresFortran

