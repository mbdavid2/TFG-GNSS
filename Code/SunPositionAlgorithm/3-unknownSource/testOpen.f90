subroutine printThreads()
  use omp_lib, only: OMP_Get_num_threads
  implicit none

  print *, "----------- test -----------"
  ! This will always print "1"
  print *,OMP_Get_num_threads()

  ! This will print the actual number of threads
  CALL OMP_SET_NUM_THREADS(3)
  !$omp parallel
  print *,OMP_Get_num_threads()
  !$omp end parallel
end subroutine