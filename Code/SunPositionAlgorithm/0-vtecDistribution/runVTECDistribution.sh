#!/bin/bash
tiDataFile1="../data/ti.2003.301.10h30m-11h30m.gz"
tiDataFile2="../data/ti.2006.340.67190s-68500s.flare.gz"
filename=vtecDistribution

zcat "$tiDataFile1" | gawk -f previewVTECDistribution.awk > vtecValues
gnuplot -e "set terminal png; set output 'vtecDistribution.png'; set title 'VTEC Distribution'; set xlabel 'Time of the day (hours)'; set ylabel 'VTEC'; set grid; plot \"vtecValues\" using 1:2 with point"
rm vtecValues