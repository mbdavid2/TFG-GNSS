#!/bin/bash

tiDataFile="../../data/ti.2003.301.10h30m-11h30m.gz"

zcat "$tiDataFile" | gawk -f previewVTECDistribution.awk  > vtecValues
gnuplot -e "plot \"vtecValues\" using 1:2 with point; pause -1"