#!/bin/bash

# Hardcoded files for now

echo "-> Running AWK script"
zcat ti.2003.301.10h30m-11h30m.gz | gawk -f processData.awk > outputTi.out
cat outputTi.out
echo "-> Compiling Fortran program"
gfortran computeVTEC.f90
echo "-> Running computeVTEC.f90"
echo "***********************"
./a.out
echo "***********************"