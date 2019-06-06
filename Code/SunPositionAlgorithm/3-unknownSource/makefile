.PHONY: *
SHELL := /bin/bash
CFLAGS = -Wall
FFLAGS = -lgfortran -lblas -llapack -lgsl -lgslcblas



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
simulatedAnnealingF = simulatedAnnealing/SimulatedAnnealing
CLASSES = $(auxiliaryF).o $(resultsDebuggerF).o $(hillClimbingF).o $(fileManagerF).o $(spikeFinderF).o $(traverseGlobeF).o $(simulatedAnnealingF).o

# ----------
# Fortran and C++ Fortran Controller
# ----------
fortranControllerF = fortranController/FortranController
leastSquaresF = fortranController/leastSquares
computeCosinesF = fortranController/computeCosinesOfCurrentSource
correlationF = fortranController/computeCorrelation
correlationBasicF = fortranController/computeCorrelationBasic
linearFitF = fortranController/x_y_sigmay_2_linear_fit.v2
FORTRAN = $(fortranControllerF).o $(correlationF).o $(correlationBasicF).o $(leastSquaresF).o $(computeCosinesF).o


main: linearFit compile run 

compile: fortranController $(CLASSES) $(FORTRAN)
	@g++ $(CFLAGS) $(CLASSES) $(FORTRAN) $(algorithmName).cc -o $(algorithmName).x $(FFLAGS)

compileAll: correlation fortranController auxiliary hillClimbing resultsDebugger fileManager spikeFinder traverseGlobe
	g++ $(CFLAGS) $(CLASSES) $(FORTRAN) $(algorithmName).cc -o $(algorithmName).x $(FFLAGS)

# ----------
# Fortran and C++ Fortran Controller
# ----------
fortranController: computeCosines correlation correlationBasic leastSquares
	@g++ $(CFLAGS) $(fortranControllerF).cc -c -o $(fortranControllerF).o

correlation: $(correlationF).f90
	@gfortran $(correlationF).f90 -c -o $(correlationF).o

correlationBasic: $(correlationBasicF).f90
	@gfortran $(correlationBasicF).f90 -c -o $(correlationBasicF).o

computeCosines: $(computeCosinesF).f90
	@gfortran $(computeCosinesF).f90 -c -o $(computeCosinesF).o

leastSquares: $(leastSquaresF).f90
	@gfortran $(leastSquaresF).f90 -c -o $(leastSquaresF).o

linearFit: $(linearFitF).f
	@gfortran $(linearFitF).f -o linearFit.x -lblas -llapack

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

simulatedAnnealing: $(simulatedAnnealingF).cc $(simulatedAnnealingF).h
	g++ $(CFLAGS) $(simulatedAnnealingF).cc -c -o $(simulatedAnnealingF).o

auxiliary: $(auxiliaryF).cc $(auxiliaryF).h
	g++ $(CFLAGS) $(auxiliaryF).cc -c -o $(auxiliaryF).o



run: $(algorithmName).x 
	./$(algorithmName).x


filterTiFilesTimeRange:
	../data/filterTiTimeRange.sh




### Plots ###
plotResultsDifferentDataSets: compile $(algorithmName).x # No linearfit target here :/
	./$(algorithmName).x > tmpResults.out
	../data/runComparisonPlot.sh
	rm tmpResults.out





# preProcessDataAWK: $(tiDataFolder)$(tiOriginalFile) $(tiDataFolder)filterDataTi.awk
# 	zcat $(tiDataFolder)$(tiOriginalFile) | gawk -f $(tiDataFolder)filterDataTi.awk > $(tiDataFolder)$(tiFilteredFile)

# plot:
# 	@./runBruteForce.sh plot

# ----------
# CLEANING
# ----------
clean:
	rm -rf */*.out */*.in */*.o */*.x 
	rm -f *.out *.in *.o *.x *.log
	rm -f ../data/*.out

cleanResults:
	rm -rf results

cleanTiFolder:
	rm -rf /home/mbdavid2/Documents/dataTi/*.out
	rm -rf ../data/filteredFiles/*.out

pristine: clean cleanResults cleanTiFolder
