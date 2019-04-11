SHELL := /bin/bash
tiDataFile := ../../data/ti.2003.301.10h30m-11h30m.gz
.PHONY: filterByBestEpochAWK

main: filterByBestEpochAWK

filterByBestEpochAWK:
	zcat $(tiDataFile) | gawk -f filterByBestEpochAWK/filterByBestEpoch.awk

cleanObjects:
	@rm -f *.out *.o *.x

clean: cleanObjects





ee: compile run

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
	g++ functions.o spikeFinder/SpikeFinder.cc bruteForce.cc -o bruteForce.x -lgfortran
	
plot:
	@./runBruteForce.sh plot

cleanResults:
	@rm -rf results

pristine: clean
	@cd spikeFinder && make clean
