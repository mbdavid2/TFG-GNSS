SHELL := /bin/bash
tiDataFile := ../../data/ti.2003.301.10h30m-11h30m.gz

prepareFiles: processTiData

run: prepareFiles
	./findSpike.x

clean:
	@rm -f *.out *.o *.x

###Plot/Debug###

processTiData:
	zcat $(tiDataFile) | gawk -f vtecDistribution.awk > processedVTEC.out

plot: processTiData
	gnuplot -e "plot \"processedVTEC.out\" using 1:2 with point; pause -1"
