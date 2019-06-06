#!/bin/bash
# tiDataFile="./ti.2003.301.10h30m-11h30m.gz"



# Aqui estan todas pero de algunas no tenemos datos :/
# strings=(
#     '2003.301,36000,41400'
#     '2011.216.13908 '
# 	'2011.210.44134 '
	# '2003.308.71000-71100 '
	# '2005.020.24200-24400  '
	# '2006.340.67300 - 67500'
	# '2001.334.3700-4000 '
	# '2001.347.51800-52200 '
	# '2002.196.72240 '
	# '2004.204.27800-28000 '
	# '2004.310.41370 '
	# '2004.313.52500 '
	# '2005.258.30990 '
	# '2012.066.4400-4700 '
	# '2012.130.50600-51000 '
	# '2012.297.11600-12000 '
	# '2013.310.35970 '
# )

strings=(
	'2016.078,30600,31600'
	# '2001.334,3900,4000'
	# '2001.347,51900,52100'
	# '2002.196,72240'
	# '2003.301,39700,39900'
	# '2003.308,70900,71200'
	# # '2004.204,27800-28000'
	# # '2004.310,41370'
	# # '2004.313,52500'
	# '2005.020,24200,24300'
	# '2005.258,30990'
	# # '2006.340,67300,67500'
	# '2011.210,44134'
	# # '2011.216, 13908'
	# '2012.066,4400,4700'
	# '2012.130,50600,51000'
	# '2012.297,11600,12000'
	# '2013.310,35970'
)

tiDataFolder="/home/mbdavid2/Documents/dataTi/"

for i in "${strings[@]}"; do
    dataInfo="$i"

  	# Split the information
	arrayInfo=(${dataInfo//,/ })

	if [ ${#arrayInfo[@]} = 2 ]; then
		let lowerLimit="${arrayInfo[1]}"-10
		let upperLimit="${arrayInfo[1]}"+10
	else
		let lowerLimit="${arrayInfo[1]}"
		let upperLimit="${arrayInfo[2]}"
	fi

	# Name the file according to the parameters
	tiDataFile="ti.""${arrayInfo[0]}"
	# outputFileName="$tiDataFile"".""$lowerLimit""-""$upperLimit"
	outputFileName="$tiDataFile"
	echo "$outputFileName"".gz"

	# Filter and compress
	zcat "$tiDataFolder""originals/""$tiDataFile" | gawk -v lowerLim="$lowerLimit" -v upperLim="$upperLimit" '{/a/; if ($3 >= lowerLim/3600 && $3 <= upperLim/3600) {print $0;}}' > "$tiDataFolder""$outputFileName"
	gzip -f "$tiDataFolder""$outputFileName" # -f to force overwrite
done