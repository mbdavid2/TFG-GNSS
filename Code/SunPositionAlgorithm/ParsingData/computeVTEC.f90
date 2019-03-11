program computeVTEC
	implicit none
	integer :: i
	integer :: status ! I/O status: 0 for success
	real :: deltaV, deltaZ

	! Input parameters from file
	real :: mapIonA, xLiA, hourA, cycleSlipA
	real :: mapIonB, xLiB, hourB, cycleSlipB

	! Constants
	real, parameter :: ALPHA = 0.105E-17

	! Formats
	200 format (F8.6, F8.4, F8.4)
	100 format (F8.6, F8.5)

	! Program
	! Opening the file for reading, old because it already exists
   	open (unit = 1, file = 'outputTi.out', status = 'old', action='read', iostat=status)

   	! Check if the open was successful
   	fileopen: if (status == 0) then
	   	read(1, *) mapIonA, xLiA, hourA
	   	write (*, 200) mapIonA, xLiA, hourA

	   	read(1, *) mapIonB, xLiB, hourB
	   	write (*, 200) mapIonB, xLiB, hourB

	   	call computeIncrease(mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)

	   	write (*, 100) deltaV, deltaZ

	else fileopen
		! Open failed
		WRITE (*, 1040) status
		1040 FORMAT (1X, 'File open failed, status = ', I6)

	end if fileopen

	close(1)
	! do i = 1,100  
 	!      read(1,*) values(i)
 	!   	end do
 	contains
		!*******************************
		!*******************************
		subroutine computeIncrease (mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
			implicit none

			! Parameters
			real, intent(in) :: mapIonA, xLiA, hourA, mapIonB, xLiB, hourB
			real, intent(out) :: deltaV, deltaZ
			
			! Variables
			real :: z
			
			! Compute deltaV
			deltaV = 3.3213231231

			! Compute deltaZ
			z = acos(1/mapIonA)
			deltaZ = z
		end subroutine computeIncrease
   	
end program computeVTEC