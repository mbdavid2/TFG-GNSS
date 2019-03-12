program computeVTEC
	implicit none

	! Variables
	integer :: status ! I/O status: 0 for success
	real, dimension(0:10,0:1) :: vtecArray

	! Input parameters from file
	real :: mapIonA, xLiA, hourA, cycleSlipA
	real :: mapIonB, xLiB, hourB, cycleSlipB

	! Constants
	real, parameter :: ALPHA = 0.105E-17

	! Formats
	200 format (F10.8, F12.8, F12.8)
	100 format (E16.10, E18.10)

	!*******************************
 	! Main Program
	!*******************************
	
	! Opening the file for reading, old because it already exists
   	open (unit = 1, file = 'ParsingData/outputTi.out', status = 'old', action='read', iostat=status)

   	! Check if the open was successful
   	fileopen: if (status == 0) then
	   	call traverseFile()
	else fileopen
		! Open failed
		WRITE (*, 1040) status
		1040 FORMAT (1X, 'File open failed, status = ', I6)

	end if fileopen

	! Close the file when finished
	close(1)

	!*******************************
 	! Procedures
	!*******************************
 	contains
 		subroutine traverseFile ()
 			integer :: i = 0
 			real :: deltaV, deltaZ
 			200 format (F10.8, F12.8, F12.8)
 			100 format (E16.10, E18.10)

 			do while (1 == 1)
 				print *, ""
 				print *, "	---New Pair---"
				read(1, *, end = 240) mapIonA, xLiA, hourA
				!write (*, 200) mapIonA, xLiA, hourA
				read(1, *, end = 240) mapIonB, xLiB, hourB
				!write (*, 200) mapIonB, xLiB, hourB

				call computeIncrease(mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
			   	vtecArray(i,0) = deltaZ
			   	vtecArray(i,1) = deltaV
			   	write (*, 100) vtecArray(i,0), vtecArray(i,1)
			   	i = i + 1
		    end do
		  	240 continue ! Jumps here when read reaches EOF
   		end subroutine traverseFile

   		!! Quizas esto deberia ser una funcion pq retorna algo¿?¿
		subroutine computeIncrease (mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
			implicit none

			! Parameters
			real, intent(in) :: mapIonA, xLiA, hourA, mapIonB, xLiB, hourB
			real, intent(out) :: deltaV, deltaZ
			
			! Variables
			real :: zA, zB
			
			! Compute deltaZ, 
			zA = (1/mapIonA)
			zB = (1/mapIonB)
			deltaZ = abs(zB - zA)
			
			! Compute deltaV (without z)
			deltaV = abs(xLiB - xLiA)/abs(hourB - hourA)
			deltaV = deltaV/ALPHA
		end subroutine computeIncrease

 	
   	
end program computeVTEC


   			! read(1, *) mapIonA, xLiA, hourA
		   	! print *, "mapIonA    xLiA       hourA"
		   	! write (*, 200) mapIonA, xLiA, hourA

		   	! read(1, *) mapIonB, xLiB, hourB
		   	! write (*, 200) mapIonB, xLiB, hourB

		   	! call computeIncrease(mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
		   	! vtecArray(0,0) = deltaZ
		   	! vtecArray(0,1) = deltaV
		   	! write (*, 100) vtecArray(0,0), vtecArray(0,1)