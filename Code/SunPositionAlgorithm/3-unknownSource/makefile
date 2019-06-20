.PHONY: *
SHELL := /bin/bash
CFLAGS = -Wall -fopenmp
FFLAGS = -lgfortran -lblas -llapack -lgsl -lgslcblas -fopenmp



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
leastSquaresDAF = fortranController/leastSquaresDynamicArrays
computeCosinesF = fortranController/computeCosinesOfCurrentSource
correlationF = fortranController/computeCorrelation
correlationBasicF = fortranController/computeCorrelationBasic
linearFitF = fortranController/x_y_sigmay_2_linear_fit.v2
FORTRAN = $(fortranControllerF).o $(correlationF).o $(correlationBasicF).o $(leastSquaresF).o $(leastSquaresDAF).o $(computeCosinesF).o


main: linearFit compile run 

compile: fortranController $(CLASSES) $(FORTRAN)
	@g++ $(CLASSES) $(FORTRAN) $(algorithmName).cc -o $(algorithmName).x $(FFLAGS) $(CFLAGS)

compileAll: correlation fortranController auxiliary hillClimbing resultsDebugger fileManager spikeFinder traverseGlobe
	g++ $(CLASSES) $(FORTRAN) $(algorithmName).cc -o $(algorithmName).x $(FFLAGS) $(CFLAGS)

# ----------
# Fortran and C++ Fortran Controller
# ----------
fortranController: computeCosines correlation correlationBasic leastSquares leastSquaresDA
	@g++ $(CFLAGS) $(fortranControllerF).cc -c -o $(fortranControllerF).o

correlation: $(correlationF).f90
	@gfortran $(FFLAGS) $(correlationF).f90 -c -o $(correlationF).o

correlationBasic: $(correlationBasicF).f90
	@gfortran $(FFLAGS)  $(correlationBasicF).f90 -c -o $(correlationBasicF).o

computeCosines: $(computeCosinesF).f90
	@gfortran $(FFLAGS) $(computeCosinesF).f90 -c -o $(computeCosinesF).o

leastSquares: $(leastSquaresF).f90
	@gfortran $(FFLAGS) $(leastSquaresF).f90 -c -o $(leastSquaresF).o

leastSquaresDA: $(leastSquaresDAF).f90
	@gfortran $(FFLAGS) $(leastSquaresDAF).f90 -c -o $(leastSquaresDAF).o

linearFit: $(linearFitF).f
	@gfortran $(FFLAGS) $(linearFitF).f -o linearFit.x -lblas -llapack

# ----------
# C++
# ----------F
spikeFinder: $(spikeFinderF).cc $(spikeFinderF).h
	g++ $(CFLAGS) $(spikeFinderF).cc -c -o $(spikeFinderF).o

traverseGlobe: $(traverseGlobeF).cc $(traverseGlobeF).h
	g++ $(CFLAGS) $(traverseGlobeF).cc -c -o $(traverseGlobeF).o -fopenmp

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

plotFinal: compile $(algorithmName).x # No linearfit target here :/
	./$(algorithmName).x > tmpResults.out
	../data/compareResultsDR_LS.sh



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
	rm -f Least\ Squares Decreasing\ Range DecreasingRange LeastSquares

cleanResults:
	rm -rf results

cleanTiFolder:
	rm -rf /home/mbdavid2/Documents/dataTi/*.out
	rm -rf ../data/filteredFiles/*.out

pristine: clean cleanResults cleanTiFolder
