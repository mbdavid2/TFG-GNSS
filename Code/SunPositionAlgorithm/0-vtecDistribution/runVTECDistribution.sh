#!/bin/bash
tiDataFile1="../data/ti.2003.301.10h30m-11h30m.gz"
tiDataFile2="../data/ti.2006.340.67190s-68500s.flare.gz"
tiDataFile3="/home/mbdavid2/Documents/ti.2016.078.07h32m-09h32m.gz"
tiDataFile4="/home/mbdavid2/Documents/dataTi/ti.2001.347.gz"
filename=vtecDistribution

zcat "$tiDataFile4" | gawk -f previewVTECDistribution.awk > vtecValues
# gnuplot -e "set terminal png; set output 'vtecDistribution.png'; set title 'VTEC Distribution'; set xlabel 'Time of the day (hours)'; set ylabel 'VTEC'; set grid; plot \"vtecValues\" using 1:2 with point"
gnuplot -e "set title 'VTEC Distribution'; set xlabel 'Time of the day (hours)'; set ylabel 'VTEC'; set grid; plot \"vtecValues\" using 1:2 with point; pause -1;"
# rm vtecValues