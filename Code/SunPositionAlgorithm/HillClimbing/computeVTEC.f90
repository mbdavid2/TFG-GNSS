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
   	! We should check the other too!!!
   	fileopen: if (status == 0) then 
	   	call traverseFile()
	else fileopen
		! Open failed
		write (*, 1040) status
		1040 format (1X, 'File open failed, status = ', I6)

	end if fileopen

	! Close the files when finished
	close(1)

	!*******************************
 	! Procedures
	!*******************************
 	contains
 		! Traverse file, 2 lines at a time, if one of them is 
 		! a flag indicating the change of pair Tx-Rx, ignores it and starts again
 		! This has to be done too with cycleslip, similar procedure
 		subroutine traverseFile ()
 			integer :: i = 0, n, m
 			real :: deltaV, deltaZ
 			character(len = 6) :: id, arc
 			200 format (F10.8, F12.8, F12.8)
 			100 format (I3, F10.4, F24.2)
 			123 format  (a4, a7)
 			320 format  (I3, F20.10, F20.10)

 			350 format  (I3, F20.10, F20.10, F20.10, a10)

 			do while (1 == 1)
 				! Line A
				read (1, *, end = 240) n, mapIonA, xLiA, hourA, id
				! write (*, 350) n, mapIonA, hourA, xLiA, id
				if (n <= -1) then
					! Start of new pair
					i = 0;
					write (*, 123) "ID: ", id
					! If first line is the flag, doesn't do anything else for the loop
					! Starts again and this time the line will have data
				else
					! Line B
					read (1, *, end = 240) m, mapIonB, xLiB, hourB, id
					if (m <= -1) then
						! Start of new pair, but the previous line had info, ignore it
						i = 0;
						write (*, 123) "ID: ", id
					else
						! Both lines have information, compute VTEC
						call computeIncrease(mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
						write (*, 100) i, hourB, deltaV*deltaZ
						! write (*, 320) i, hourA, mapIonA
						i = i + 1
					end if
				end if


				! call computeIncrease(mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
			   	
			   	! vtecArray(i,0) = deltaV quizas no hace falta guardar nada, output directamente
			   	! vtecArray(i,1) = deltaZ
			   	! write (*, 100) i, hourB, deltaV*deltaZ
			   	
		    end do
		  	240 continue ! Jumps here when read reaches EOF
   		end subroutine traverseFile

 		! BASIC TRAVERSE FILE: traverses the file line by line and restarts i whenever there's a new pair
 	 	! subroutine traverseFile ()
 			! integer :: i = 0, n, m
 			! real :: deltaV, deltaZ
 			! character(len = 6) :: id, arc
 			! 200 format (F10.8, F12.8, F12.8)
 			! 100 format (I3, F10.4, F24.2)
 			! 123 format  (a4, a7)
 			! 320 format  (I3, F20.10, F20.10)

 			! 350 format  (I3, F20.10, F20.10, F20.10, a10)

 			! do while (1 == 1)
				! read (1, *, end = 240) n, mapIonA, xLiA, hourA, id
				! ! write (*, 350) n, mapIonA, hourA, xLiA, id
				! if (n <= -1) then
				! 	i = 0;
				! 	write (*, 123) "ID: ", id
				! else
				! 	write (*, 320) i, hourA, mapIonA
				! 	i = i + 1
				! end if


				! ! call computeIncrease(mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
			   	
			 !   	! vtecArray(i,0) = deltaV quizas no hace falta guardar nada, output directamente
			 !   	! vtecArray(i,1) = deltaZ
			 !   	! write (*, 100) i, hourB, deltaV*deltaZ
			   	
		  !   end do
		  ! 	240 continue ! Jumps here when read reaches EOF
   	! 	end subroutine traverseFile

 		! subroutine traverseFileAndWrite ()
 		! 	integer :: i = 0, n, m
 		! 	real :: deltaV, deltaZ
 		! 	character(len = 6) :: id, arc
 		! 	200 format (F10.8, F12.8, F12.8)
 		! 	100 format (I3, F10.4, F24.2)
 		! 	123 format  (a10, i10)

 		! 	open (unit = 2, file = 'fortranResults/0.data', status = 'replace', iostat=status)

 		! 	do while (1 == 1)
			! 	read (1, *, end = 240) n, mapIonA, xLiA, hourA, arc, id
			! 	read (1, *, end = 240) m, mapIonB, xLiB, hourB, arc, id

			! 	if (n <= -1) then
			! 		i = 0;
			! 		close(2)
			! 		open (unit = 2, file = 'fortranResults/'//id//'.data', status = 'replace', iostat=status)
			! 		!write (2, 123) "fqin, id: ", n
			! 	else if (m <= -1) then
			! 		i = 0;
			! 		close(2)
			! 		open (unit = 2, file = 'fortranResults/'//id//'.data', status = 'replace', iostat=status)
			! 		!write (2, 123) "fqin, id: ", m
			! 	end if

			! 	call computeIncrease(mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
			   	
			!    	! vtecArray(i,0) = deltaV quizas no hace falta guardar nada, output directamente
			!    	! vtecArray(i,1) = deltaZ
			!    	write (2, 100) i, hourB, deltaV*deltaZ
			!    	i = i + 1
		 !    end do
		 !  	240 continue ! Jumps here when read reaches EOF
		 !  	close(2)
   ! 		end subroutine traverseFileAndWrite

   		!! Quizas esto deberia ser una funcion pq retorna algo¿?¿
		subroutine computeIncrease (mapIonA, xLiA, hourA, mapIonB, xLiB, hourB, deltaV, deltaZ)
			implicit none

			! Parameters
			real, intent(in) :: mapIonA, xLiA, hourA, mapIonB, xLiB, hourB
			real, intent(out) :: deltaV, deltaZ
			
			! Variables
			real :: zA, zB
			
			! Compute deltaZ, hay que hacerlo?¿?
			zA = acos(1/mapIonA)
			zB = acos(1/mapIonB)
			deltaZ = abs(zB - zA)
			
			! Compute deltaV (without z)
			! esto se puede evitar? el incremento de tiempo siempre 30 segundos no??
			deltaV = abs(xLiB - xLiA)/abs(hourB - hourA) 
			deltaV = deltaV/ALPHA
		end subroutine computeIncrease
end program computeVTEC