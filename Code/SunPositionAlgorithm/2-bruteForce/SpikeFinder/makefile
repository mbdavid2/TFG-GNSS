SHELL := /bin/bash
tiDataFile := ../../data/ti.2003.301.10h30m-11h30m.gz

prepareFiles: compile processTiData

compile: SpikeFinder.cc findSpike.cc
	g++ SpikeFinder.cc findSpike.cc -o findSpike.x
	@rm -f *.o

run: prepareFiles
	./findSpike.x

clean:
	@rm -f *.out *.o *.x






###Plot/Debug###

storeOutput: prepareFiles
	./findSpike.x > meanResults.out

processTiData:
	zcat $(tiDataFile) | gawk -f vtecDistribution.awk > vtecAllDay.out

plotTiData: processTiData
	gnuplot -e "plot \"vtecAllDay.out\" using 1:2 with point; pause -1"

plotOrderedEpochs: prepareFiles storeOutput
	gnuplot -e "plot \"meanResults.out\" using 1:2 with point; pause -1"
