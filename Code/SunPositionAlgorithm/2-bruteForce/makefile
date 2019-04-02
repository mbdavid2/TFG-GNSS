all: functions.o a.out

functions.o: fortranFunctions.f90
		gfortran fortranFunctions.f90 -c -o functions.o

a.out: functions.o bruteForce.cc
		g++ functions.o bruteForce.cc -o a.out -lgfortran

cleanResults:
		rm -r results

clean : 
		rm *.out *.o