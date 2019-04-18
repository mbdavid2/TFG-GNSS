.PHONY: pristine clean cleanResults correlation spikeFinder traverseGlobe
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

main: compile run 

compile: correlation spikeFinder traverseGlobe
	g++ $(CFLAGS) $(correlation).o $(spikeFinder).o $(traverseGlobe).o $(algorithmName).cc -o $(algorithmName).x $(FFLAGS)

correlation: $(correlation).f90
	gfortran $(correlation).f90 -c -o $(correlation).o

spikeFinder: $(spikeFinder).cc
	g++ $(spikeFinder).cc -c -o $(spikeFinder).o

traverseGlobe: $(traverseGlobe).cc
	g++ $(traverseGlobe).cc -c -o $(traverseGlobe).o

run: $(tiDataFolder)$(tiFilteredFile) $(algorithmName).x 
	./$(algorithmName).x



preProcessDataAWK: $(tiDataFolder)$(tiOriginalFile) $(tiDataFolder)filterDataTi.awk
	zcat $(tiDataFolder)$(tiOriginalFile) | gawk -f $(tiDataFolder)filterDataTi.awk > $(tiDataFolder)$(tiFilteredFile)

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
