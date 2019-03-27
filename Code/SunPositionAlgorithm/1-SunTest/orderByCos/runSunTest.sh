#!/bin/bash

# Hardcoded files for now
showOutput=1
tiDataFile="../../data/ti.2003.301.10h30m-11h30m.gz"
# tiDataFile="/home/mbdavid2/Documents/WrongTi/ti.2003.301.09-10.gz"

echo "-> Running AWK script"
zcat "$tiDataFile" | gawk -f processDataSun.awk  > outputTi.out
# if [ "$1" != "plot" ];then
# cat outputTi.out
# fi
echo "-> Compiling sunTest.f90"
gfortran sunTest.f90
echo "-> Running sunTest.f90"
if [ "$1" == "plot" ];then
	./a.out > resultsToPlot
	rm a.out
	echo "-> Plot the results"
	gnuplot -e "plot \"resultsToPlot\" using 1:2 with point; pause -1"
else
	./a.out > results
	cat results | gawk -f computeSum.awk
	rm a.out
fi

# plot [10.5:11.5] "test" using 1:2 with point