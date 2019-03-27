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
gfortran bruteForce2.f90
rm -r results
mkdir -p results/
echo "-> Running bruteForce2.f90"
if [ "$1" == "plot" ];then
	./a.out
	rm a.out
	rm outputTi.out
	echo "-> Plotting the results"
	for filename in results/*; do
        # ./MyProgram.exe "$filename" "Logs/$(basename "$filename" .txt)_Log$i.txt"
        gnuplot -e "set terminal png; set output '$filename.png'; plot '$filename' using 1:2 with point;"
	done
	find results -type f ! -regex ".*\.\(jpg\|png\)" -delete
	nautilus results
else
	echo "-> NOT Plotting the results"
	./a.out
	rm a.out
fi

# plot [10.5:11.5] "test" using 1:2 with point