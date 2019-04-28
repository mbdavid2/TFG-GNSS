.PHONY: pristine clean cleanResults correlation spikeFinder traverseGlobe fileManager resultsDebugger auxiliary
SHELL := /bin/bash
CFLAGS = -Wall
FFLAGS = -lgfortran

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
spikeFinder = spikeFinder/SpikeFinder
traverseGlobe = traverseGlobe/TraverseGlobe
correlation = computeCorrelation/computeCorrelation
fileManager = fileManager/FileManager
resultsDebugger = resultsDebugger/ResultsDebugger
auxiliary = auxiliary/auxiliary

main: compile run 

compile: correlation auxiliary resultsDebugger fileManager spikeFinder traverseGlobe
	g++ $(CFLAGS) $(auxiliary).o $(resultsDebugger).o $(fileManager).o $(correlation).o $(spikeFinder).o $(traverseGlobe).o $(algorithmName).cc -o $(algorithmName).x $(FFLAGS)

correlation: $(correlation).f90
	gfortran $(correlation).f90 -c -o $(correlation).o

spikeFinder: $(spikeFinder).cc $(spikeFinder).h
	g++ $(spikeFinder).cc -c -o $(spikeFinder).o

traverseGlobe: $(traverseGlobe).cc $(traverseGlobe).h
	g++ $(traverseGlobe).cc -c -o $(traverseGlobe).o

fileManager: $(fileManager).cc $(fileManager).h
	g++ $(fileManager).cc -c -o $(fileManager).o

resultsDebugger: $(resultsDebugger).cc $(resultsDebugger).h
	g++ $(resultsDebugger).cc -c -o $(resultsDebugger).o

auxiliary: $(auxiliary).cc $(auxiliary).h
	g++ $(auxiliary).cc -c -o $(auxiliary).o 

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
