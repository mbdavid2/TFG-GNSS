SHELL := /bin/bash
CFLAGS = -Wall
FFLAGS = -lgfortran
tiDataFile := ../../data/ti.2003.301.10h30m-11h30m.gz
spikeFolder = spikeFinder
algorithmName = algorithm
.PHONY: filterByBestEpochAWK

spikeFinder = spikeFinder/SpikeFinder.cc
traverseGlobe = traverseGlobe/TraverseGlobe.cc

main: compile 

compile: fortranFunctions $(algorithmName).cc $(spikeFolder)/SpikeFinder.cc
	g++ $(CFLAGS) functions.o $(spikeFinder) $(traverseGlobe) $(algorithmName).cc -o $(algorithmName).x $(FFLAGS)

fortranFunctions: fortranFunctions/fortranFunctions.f90
	gfortran fortranFunctions/fortranFunctions.f90 -c -o functions.o

run: compile
	./$(algorithmName).x

plot:
	@./runBruteForce.sh plot

clean:
	@rm -f *.out *.o *.x

cleanResults:
	@rm -rf results

pristine: clean cleanObjects











# preProcessDataAWK:
# 	zcat $(tiDataFile) | gawk -f preProcessDataAWK/preProcessData.awk

# filterByBestEpochAWK:
# 	zcat $(tiDataFile) | gawk -f filterByBestEpochAWK/filterByBestEpoch.awk


# ee: compile run

# # run:
# # 	@mkdir -p results/
# # 	@rm -r results
# # 	@mkdir -p results/
# # 	@./bruteForce.x

# # compile: preProcessAWK fortranFunctions bruteForce

# preProcessAWK:
# 	@cd spikeFinder && make

# fortranFunctions: fortranFunctions/fortranFunctions.f90
# 	gfortran fortranFunctions/fortranFunctions.f90 -c -o functions.o

# bruteForce: fortranFunctions bruteForce.cc spikeFinder/SpikeFinder.cc
# 	g++ functions.o spikeFinder/SpikeFinder.cc bruteForce.cc -o bruteForce.x -lgfortran
	
# plot:
# 	@./runBruteForce.sh plot

# cleanResults:
# 	@rm -rf results

# pristine: clean
# 	@cd spikeFinder && make clean
