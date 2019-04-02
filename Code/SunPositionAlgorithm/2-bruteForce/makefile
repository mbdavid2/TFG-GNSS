compile: functions.o a.out

functions.o: fortranFunctions.f90
		gfortran fortranFunctions.f90 -c -o functions.o

a.out: functions.o bruteForce.cc
		g++ functions.o bruteForce.cc -o a.out -lgfortran

removeResults:
		rm -r results

run: compile
		./runBruteForce.sh

plot: compile
		./runBruteForce.sh plot

clean : 
		rm *.out *.o -r results/
