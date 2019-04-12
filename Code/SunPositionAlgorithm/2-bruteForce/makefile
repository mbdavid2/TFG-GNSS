SHELL := /bin/bash
CFLAGS = -Wall
.PHONY: fortranFunctions

main: compile run

run:
	@mkdir -p results/
	@rm -r results
	@mkdir -p results/
	@./bruteForce.x

compile: preProcessAWK fortranFunctions bruteForce

preProcessAWK:
	@cd spikeFinder && make

fortranFunctions: fortranFunctions/fortranFunctions.f90
	gfortran fortranFunctions/fortranFunctions.f90 -c -o functions.o

bruteForce: fortranFunctions bruteForce.cc spikeFinder/SpikeFinder.cc
	g++ $(CFLAGS) functions.o spikeFinder/SpikeFinder.cc bruteForce.cc -o bruteForce.x -lgfortran
	
plot:
	@./runBruteForce.sh plot

cleanResults:
	@rm -rf results

cleanObjects:
	@rm -f *.out *.o *.x

clean: cleanObjects cleanResults

pristine: clean
	@cd spikeFinder && make clean
