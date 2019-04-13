#!/bin/bash
tiDataFile="./ti.2003.301.10h30m-11h30m.gz"

zcat "$tiDataFile" | gawk -f filterDataTi.awk > filterTi.2003.301.10h30m-11h30m.out
# gzip filterTi.2003.301.10h30m-11h30m
