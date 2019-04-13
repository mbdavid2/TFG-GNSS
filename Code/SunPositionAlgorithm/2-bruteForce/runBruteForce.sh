#!/bin/bash

# Hardcoded files for now
# tiDataFile="../data/ti.2003.301.10h30m-11h30m.gz"

# echo "-> Running AWK script"
# zcat "$tiDataFile" | gawk -f processDataSun.awk  > outputTi.out
# if [ "$1" != "plot" ];then
# cat outputTi.out
# fi
rm -r results
mkdir -p results/
# echo "-> Running bruteForce algorithm"
if [ "$1" == "plot" ];then
	# ./bruteForce.x
	# rm outputTi.out
	echo "[Bash: Plotting the results]"
	for filename in results/*; do
        gnuplot -e "set terminal png; set output '$filename.png'; plot '$filename' using 1:2 with point;"
	done
	find results -type f ! -regex ".*\.\(jpg\|png\)" -delete
	# nautilus -q
	# nautilus results
else
	# ./bruteForce.x
	echo "-> NOT Plotting the results: only data"
	# nautilus -q
	# nautilus results
fi

# rm *.out *.o

