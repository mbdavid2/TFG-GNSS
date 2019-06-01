#!/bin/bash
# tiDataFile="./ti.2003.301.10h30m-11h30m.gz"




strings=(
    'ti.2003.301.gz,10,11.5'
)
for i in "${strings[@]}"; do
    dataInfo="$i"
    # Split
	arrayInfo=(${dataInfo//,/ })

	# Save each parameter
	tiDataFile=${arrayInfo[0]}
	lowerLimit=${arrayInfo[1]}
	upperLimit=${arrayInfo[2]}

	# Filter the file
	tiDataFileOut=${tiDataFile::-2}
	outputFileName="$tiDataFileOut$lowerLimit""-""$upperLimit"
	echo $outputFileName
	# zcat "$tiDataFile" | gawk -v lowerLim="$lowerLimit" -v upperLim="$upperLimit" '{/a/; if ($3 >= lowerLim && $3 <= upperLim) {print $0;}}' > $outputFileName
	# gzip $outputFileName
done