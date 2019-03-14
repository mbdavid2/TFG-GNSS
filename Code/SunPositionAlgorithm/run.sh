#!/bin/bash

# Hardcoded files for now
showOutput=1
maxRecords=50000
tiDataFile="ParsingData/ti.2003.301.10h30m-11h30m.gz"
plot="plot"
# nOfLines="$(wc -l "$tiDataFile")"
# echo ${"$nOfLines"[0]}

echo "-> Running AWK script"
zcat "$tiDataFile" | gawk -v maxRecords="$maxRecords" -f ParsingData/processData.awk  > ParsingData/outputTi.out
# if [ "$1" != "plot" ];then
# 	cat ParsingData/outputTi.out
# fi
echo "-> Compiling computeVTEC.f90"
gfortran HillClimbing/computeVTEC.f90
echo "-> Running computeVTEC.f90"
if [ "$1" == "plot" ];then
	./a.out > fortranResults
	rm a.out
	echo "-> Plot the results"
	gnuplot -e "splot \"fortranResults\" using 1:2:3 with lines; pause -1"
else
	echo "  n 	 time 	  VTEC"
	./a.out
	rm a.out
fi

# plot [10.5:11.5] "test" using 1:2 with point