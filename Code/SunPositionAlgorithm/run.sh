#!/bin/bash

# Hardcoded files for now
maxRecords=50000
tiDataFile="ParsingData/ti.2003.301.10h30m-11h30m.gz"
nOfLines="$(wc -l "$tiDataFile")"
# echo ${"$nOfLines"[0]}

echo "-> Running AWK script"
zcat "$tiDataFile" | gawk -v maxRecords="$maxRecords" -f ParsingData/processData.awk  > ParsingData/outputTi.out
cat ParsingData/outputTi.out
echo "-> Compiling Fortran program"
gfortran HillClimbing/computeVTEC.f90
echo "-> Running computeVTEC.f90"
echo "-----------------------"
./a.out
echo "-----------------------"