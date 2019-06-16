double precision function leastSquaresFortran(inputFileName, numRows, iterations, solutionRa, solutionDec, totalEstimatedError)
	implicit none

	!! NON_DYNAMIC VERSION: the invalid rows are filled with 0s, computations work (faster than dynamic version)?

	!! Parameters
	double precision, parameter :: PI = datan(1.d0)*4.d0
	double precision, parameter :: COSINE_THRESHOLD = -0.1

	character(len=20), intent(in) :: inputFileName
	double precision :: rxyPearsonCoefficient
	integer, intent(in) :: numRows, iterations
	double precision :: solutionRa, solutionDec, totalEstimatedError

	! print *, "_________________"
	call iterateLeastSquares()
	
	! call leastSquares(1)
	 
	! TODO: we should pass the real number of rows

	rxyPearsonCoefficient = 23232
	return

	contains
		subroutine iterateLeastSquares()
			implicit none
			integer :: iteration
			double precision :: bestRa, bestDec, bestError
			double precision, dimension(0:numRows) :: estimationMatrix
			
			bestError = 100

			do iteration = 0, iterations-1
				call leastSquares(iteration, solutionRa, solutionDec, estimationMatrix)
				if (totalEstimatedError <= bestError) then
					bestError = totalEstimatedError
					bestRa = solutionRa
					bestDec = solutionDec
				end if
				! print *, "Iteration: ", iteration, " | Ra, Dec: ", solutionRa, solutionDec, " Error : ", totalEstimatedError
			end do

			! Return the best solution
			totalEstimatedError = bestError
			solutionRa = bestRa
			solutionDec = bestDec
			! print *, "BEST | Ra, Dec: ", solutionRa, solutionDec, " Error : ", totalEstimatedError
		end subroutine iterateLeastSquares

		subroutine leastSquares(iteration, solutionRa, solutionDec, estimationMatrix)
			implicit none
			integer, intent(in) :: iteration
			double precision :: solutionRa, solutionDec, pof
			double precision, dimension(0:numRows) :: matrixVTEC, estimationMatrix, resultsSum
			double precision, dimension (0:numRows, 0:3) :: matrixIPP
			double precision, dimension (0:3) :: solution

			call storeMatrixData(matrixVTEC, matrixIPP, iteration, solutionRa, solutionDec, estimationMatrix)
			! call printMatrices(matrixVTEC, matrixIPP)
			call matrixComputations(solution, matrixIPP, matrixVTEC)
			call obtainSourceLocation(solution, solutionRa, solutionDec)
			estimationMatrix = matmul(matrixIPP, solution)
			pof = computePOF(matrixVTEC, estimationMatrix, resultsSum)
			totalEstimatedError = totalEstimatedError
		end subroutine leastSquares

		subroutine storeMatrixData(matrixVTEC, matrixIPP, iteration, solutionRa, solutionDec, estimationMatrix)
			implicit none
			integer, intent(in) :: iteration
			double precision, intent(in) :: solutionRa, solutionDec
			double precision, dimension(0:numRows) :: matrixVTEC, estimationMatrix, resultsSum
			double precision, dimension (0:numRows, 0:3), intent(out) :: matrixIPP
			double precision :: vtec, raIPP, decIPP, pof
			double precision :: xIPP, yIPP, zIPP
			integer :: i, validSample, nUsedSamples

			if (iteration /= 0) then
				pof = computePOF(matrixVTEC, estimationMatrix, resultsSum)
				print *, "pof", pof
			end if

			nUsedSamples = 0

			call openFile(inputFileName)

			do i = 0, numRows
				read (1, *, end = 240) vtec, raIPP, decIPP
				validSample = 1

				if (iteration /= 0) then
					! validSample = checkOutlier(solutionRa, solutionDec, raIPP, decIPP)
					print *, "(valor real - estimado) =", abs(resultsSum(i)), " | pof =", pof
					if (abs(resultsSum(i)) > 3*pof) then
						validSample = 0
					end if
				end if

				if (validSample == 1) then
					nUsedSamples = nUsedSamples + 1
					call computeComponentsIPP(raIPP, decIPP, xIPP, yIPP, zIPP)
				else
					vtec = 0
					xIPP = 0
					yIPP = 0
					zIPP = 0
				end if
				
				matrixVTEC(i) = vtec
				matrixIPP(i, 0) = xIPP
				matrixIPP(i, 1) = yIPP
				matrixIPP(i, 2) = zIPP
				matrixIPP(i, 3) = 1
			end do
			240 continue
			! print *, "Number of used samples: ", nUsedSamples
			close(1)
		end subroutine storeMatrixData

		double precision function computePOF(matrixVTEC, estimationMatrix, resultsSum)
			implicit none
			integer :: i, vtecSize, consideredSamples
			double precision :: pof, totalSum
			double precision, dimension(0:numRows) :: matrixVTEC, estimationMatrix, resultsSum

			vtecSize = size(matrixVTEC)
			totalSum = 0
			consideredSamples = 0
			do i = 0, vtecSize-1
				! print *, "Real: ", matrixVTEC(i), "Est: ", estimationMatrix(i)
				if (matrixVTEC(i) /= 0) then
					resultsSum(i) = matrixVTEC(i) - estimationMatrix(i)
					totalSum = totalSum + resultsSum(i)*resultsSum(i)
					consideredSamples = consideredSamples + 1
				end if
			end do
			pof = sqrt(totalSum/consideredSamples)
			return
		end function computePOF

		subroutine matrixComputationsLapack(solution, A, Y)
			implicit none
			double precision, dimension (0:3), intent(out) :: solution
			double precision, dimension (0:numRows), intent(in) :: Y
			double precision, dimension (:, :) :: A
			double precision, dimension (0:3, 0:numRows) :: transposedA, innerMat
			double precision, dimension (0:numRows, 0:3) :: invMult
			double precision, dimension(size(A,1)) :: work  ! work array for LAPACK
			integer :: n, info

			external DGELS

			call DGELS('N', numRows, 4, 1, A, numRows, Y, numRows, work, numRows, info)

			if (info /= 0) then
				stop 'Matrix is numerically singular!'
			end if
		end subroutine matrixComputationsLapack

		subroutine matrixComputations(solution, A, Y)
			implicit none
			double precision, dimension (0:3), intent(out) :: solution
			double precision, dimension (0:numRows), intent(in) :: Y
			double precision, dimension (0:numRows, 0:3), intent(in) :: A
			double precision, dimension (0:3, 0:numRows) :: transposedA, innerMat
			double precision, dimension (0:numRows, 0:3) :: invMult
			double precision, dimension (0:3, 0:3) :: covMat

			transposedA = transpose(A)
			covMat = inv(matmul(transposedA, A))
			totalEstimatedError = sqrt(covMat(0,0)) + sqrt(covMat(1,1)) + sqrt(covMat(2,2))
			! print *, totalEstimatedError
			
			! invMult = inv(matmul(transposedA, A))
			
			solution = matmul(matmul(covMat, transposedA), y) ! esto dejarlo mas bonito???
		end subroutine matrixComputations

		subroutine obtainSourceLocation(solution, solutionRa, solutionDec)
			implicit none
			double precision, dimension (0:3), intent(in) :: solution
			double precision, intent(out) :: solutionRa, solutionDec
			double precision :: a, b, g, mod, radianRa, radianDec
			double precision :: X, Y, Z

			a = solution(0)
			b = solution(1)
			g = solution(2)

			mod = sqrt(a*a + b*b + g*g)
			! print *, "Gradient: ", mod ! Pendiente

			X = a/mod
			Y = b/mod
			Z = g/mod

			radianRa = datan2(Y,X)
			radianDec = dasin(Z)

			if (radianRa < 0) then
				radianRa = radianRa + 2*PI
			end if

			solutionRa = toDegree(radianRa)
			solutionDec = toDegree(radianDec)
		end subroutine obtainSourceLocation

		integer function checkOutlier(solutionRa, solutionDec, raIPP, decIPP)
			implicit none
			double precision, intent(in) :: solutionRa, solutionDec, raIPP, decIPP
			double precision :: sourceZenithAngle
			integer :: validSample, returnValue

			sourceZenithAngle = computeSourceZenithAngle (solutionRa, solutionDec, raIPP, decIPP)
			if (sourceZenithAngle >= COSINE_THRESHOLD) then
				validSample = 1
			else
				validSample = 0
			end if
			returnValue = validSample
			return
		end function checkOutlier

		double precision function computeSourceZenithAngle (raSource, decSource, raIPP, decIPP)
			implicit none
			double precision, intent(in) :: raSource, decSource, raIPP, decIPP
			double precision :: sourceZenithAngle

			sourceZenithAngle = sin(decIPP)*sin(decSource) + cos(decIPP)*cos(decSource)*cos(raIPP - raSource)
			return
		end function computeSourceZenithAngle

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
		  double precision, intent(in) :: degree
		  double precision :: radians

		  radians = (degree*PI)/180
		  return
		end function toRadian

		double precision function toDegree(radians)
		  implicit none
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

		subroutine openFile(inputFileName)
			implicit none
			character(len = 20), intent(in) :: inputFileName
			integer :: status ! I/O status: 0 for success

			open (unit = 1, file = inputFileName, status='old', action='read', iostat=status)

		   	if (status /= 0) then 
				write (*, 1040) status
				1040 format (1X, 'File open failed, status = ', I6)
			end if
		end subroutine openFile

		subroutine printMatrices(matrixVTEC, matrixIPP)
			implicit none
			double precision, dimension (:), intent(in) :: matrixVTEC
			double precision, dimension (0:numRows, 0:3), intent(in) :: matrixIPP
			integer :: vtecSize, i

			vtecSize = size(matrixVTEC)
			! do i = 0, vtecSize-1
			! 	print *, "VTEC:", matrixVTEC(i), "	|	IPP:", matrixIPP(i,0), matrixIPP(i,1), matrixIPP(i,2), matrixIPP(i,3)
			! end do
			print *, "size: ", vtecSize
		end subroutine printMatrices
end function leastSquaresFortran

