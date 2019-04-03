SHELL := /bin/bash

compile: preProcessAWK fortranFunctions bruteForce

preProcessAWK:
	@cd SpikeFinder && make

fortranFunctions: fortranFunctions.f90
	gfortran fortranFunctions.f90 -c -o functions.o

bruteForce: fortranFunctions bruteForce.cc
	g++ functions.o SpikeFinder/SpikeFinder.cc bruteForce.cc -o bruteForce.x -lgfortran

run: compile
	@rm -r results
	@mkdir -p results/
	./bruteForce.x
	# ./runBruteForce.sh

plot: compile
	./runBruteForce.sh plot

cleanResults:
	@rm -rf results

cleanObjects:
	@rm -f *.out *.o 

clean: cleanObjects cleanResults
