SHELL := /bin/bash

compile: fortranFunctions bruteForce

fortranFunctions: fortranFunctions.f90
	gfortran fortranFunctions.f90 -c -o functions.o

bruteForce: fortranFunctions bruteForce.cc
	g++ functions.o SpikeFinder/SpikeFinder.cc bruteForce.cc -o bruteForce.x -lgfortran

run: compile
	./runBruteForce.sh

plot: compile
	./runBruteForce.sh plot

cleanResults:
	@rm -rf results

cleanObjects:
	@rm -f *.out *.o 

clean: cleanObjects cleanResults
