.PHONY: *
SHELL := /bin/bash
CFLAGS = -Wall
FFLAGS = -lgfortran -lblas -llapack



algorithmName = algorithm

# ----------
# DATA FILES
# ----------
tiOriginalFile = ti.2003.301.10h30m-11h30m.gz
tiFilteredFile = filterTi.2003.301.10h30m-11h30m.out
tiDataFolder = ../data/

# ----------
# CLASSES
# ----------
spikeFinderF = spikeFinder/SpikeFinder
traverseGlobeF = traverseGlobe/TraverseGlobe
fileManagerF = fileManager/FileManager
resultsDebuggerF = resultsDebugger/ResultsDebugger
hillClimbingF = hillClimbing/HillClimbing
auxiliaryF = auxiliary/Auxiliary
CLASSES = $(auxiliaryF).o $(resultsDebuggerF).o $(hillClimbingF).o $(fileManagerF).o $(spikeFinderF).o $(traverseGlobeF).o

# ----------
# Fortran and C++ Fortran Controller
# ----------
fortranControllerF = fortranController/FortranController
leastSquaresF = fortranController/leastSquares
correlationF = fortranController/computeCorrelation
FORTRAN = $(fortranControllerF).o $(correlationF).o $(leastSquaresF).o


main: compile run 

compile: correlation fortranController auxiliary hillClimbing resultsDebugger fileManager spikeFinder traverseGlobe
	g++ $(CFLAGS) $(CLASSES) $(FORTRAN) $(algorithmName).cc -o $(algorithmName).x $(FFLAGS)

# ----------
# Fortran and C++ Fortran Controller
# ----------
fortranController: correlation leastSquares
	g++ $(CFLAGS) $(fortranControllerF).cc -c -o $(fortranControllerF).o

correlation: $(correlationF).f90
	gfortran $(correlationF).f90 -c -o $(correlationF).o

leastSquares: $(leastSquaresF).f90
	gfortran $(leastSquaresF).f90 -c -o $(leastSquaresF).o

# ----------
# C++
# ----------F
spikeFinder: $(spikeFinderF).cc $(spikeFinderF).h
	g++ $(CFLAGS) $(spikeFinderF).cc -c -o $(spikeFinderF).o

traverseGlobe: $(traverseGlobeF).cc $(traverseGlobeF).h
	g++ $(CFLAGS) $(traverseGlobeF).cc -c -o $(traverseGlobeF).o

fileManager: $(fileManagerF).cc $(fileManagerF).h
	g++ $(CFLAGS) $(fileManagerF).cc -c -o $(fileManagerF).o

resultsDebugger: $(resultsDebuggerF).cc $(resultsDebuggerF).h
	g++ $(CFLAGS) $(resultsDebuggerF).cc -c -o $(resultsDebuggerF).o

hillClimbing: $(hillClimbingF).cc $(hillClimbingF).h
	g++ $(CFLAGS) $(hillClimbingF).cc -c -o $(hillClimbingF).o

auxiliary: $(auxiliaryF).cc $(auxiliaryF).h
	g++ $(CFLAGS) $(auxiliaryF).cc -c -o $(auxiliaryF).o



run: $(algorithmName).x 
	./$(algorithmName).x











# preProcessDataAWK: $(tiDataFolder)$(tiOriginalFile) $(tiDataFolder)filterDataTi.awk
# 	zcat $(tiDataFolder)$(tiOriginalFile) | gawk -f $(tiDataFolder)filterDataTi.awk > $(tiDataFolder)$(tiFilteredFile)

# plot:
# 	@./runBruteForce.sh plot

# ----------
# CLEANING
# ----------
clean:
	@rm -rf */*.out */*.in */*.o */*.x 
	@rm -f *.out *.in *.o *.x 

cleanResults:
	@rm -rf results

pristine: clean cleanResults
