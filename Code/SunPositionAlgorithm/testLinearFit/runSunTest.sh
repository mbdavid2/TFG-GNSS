#!/bin/bash

# Hardcoded files for now
showOutput=1
tiDataFile="../data/ti.2003.301.10h30m-11h30m.gz"
# tiDataFile="/home/mbdavid2/Documents/WrongTi/ti.2003.301.09-10.gz"

echo "-> Running AWK script"
zcat "$tiDataFile" | gawk -f processDataSun.awk  > outputTi.out
# if [ "$1" != "plot" ];then
# cat outputTi.out
# fi
echo "-> Compiling sunTest.f90"
gfortran x_y_sigmay_2_linear_fit.v2.f -o linearFit.x -lblas -llapack 
gfortran createPlot.f90 sunTestMain.f90
echo "-> Running sunTest.f90"
if [ "$1" == "plot" ];then
	./a.out > resultsToPlot
	rm a.out
	echo "-> Plot the results"
	gnuplot -e "set terminal png; set output 'result.png'; set title 'Time=11.05h || ra=212.338 || dec=-13.060'; set xlabel 'Cosine of solar-zenith angle'; set ylabel 'VTEC'; set grid; plot \"resultsToPlot\" using 1:2 with point"
else
	./a.out
	rm a.out
fi
# rm resultsToPlot
# rm *.out
rm *.mod

# plot [10.5:11.5] "test" using 1:2 with point

cat resultsToPlot | ./linearFit.x 1 5 > resultsFitted

cat resultsFitted | gawk -e '{/a/; if ($6 == "T" && $3 >= 0.01) {print $0}}' > trueFitted
cat resultsFitted | gawk -e '{/a/; if ($6 == "F") {print $0}}' > falseFitted

gnuplot -e "set grid; plot \"resultsToPlot\" using 1:2 with point, \"trueFitted\" using 1:2 with point; pause -1;"