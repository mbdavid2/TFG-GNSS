# fileName="resultsAllNombreRaroDiscardDay.sigma1.6.LSCorrectaPrimeraIteracion.txt"
# fileName="resultsBestErrorEachEpoch.txt"
# fileName="resultsAllIPPs.txt"
# fileName="resultsNightTwoEpochs.txt"
# fileName="results0.2Night2Epochs.txt"
# fileName="results0.2Night1Epochs.txt"
# fileName="resultsAllNombreRaroDiscardDay.sigma3.4.txt"
# fileName="resultsAllNombreRaroDiscardDay.sigma1.6.LSCorrectaPrimeraIteracion.txt"


strings=(
	# '2016.078,29600,31000'
	'allIPPs2EpochsLinearFit.txt'
	# 'results0.1Night2EpochsWithLinearFit.txt'
	# 'cos0.2Night1Epochs.txt'
	# 'cos0.2Night2Epochs10best.txt'
	# 'cos0.2Night2Epochs.txt'
	# '2001.334,3900,4000'
	# '2001.347,51900,52100'
	# '2002.196,72240'
	# '2003.301,39700,39900'
)

# cat "$fileName" | gawk '{/a/; if ($6 < $7) { print $1 " " $6 } else { print $1 " " $7 }}' > "$fileName""Best"

# fileName="$fileName""Best"





for i in "${strings[@]}"; do
    fileName="$i"

	titleAndLabels="set xlabel 'Data set'; set ylabel 'Estimation error'; set yrange [0:180];"
	gnuplot -e "$titleAndLabels""set grid; set title 'Best'; plot  \"""$fileName""\" using 1:3 smooth unique;"
#     mkdir -p "plots_""$fileName"
#     titleAndLabels="set terminal png; set output '""plots_""$fileName""/best"".png'; set xlabel 'Data set'; set ylabel 'Estimation error'; set yrange [0:180];"
#     # gnuplot -e "$titleAndLabels""set grid; set title 'Best'; plot  \"""$fileName""\"  using 1:8 smooth unique;"
#     gnuplot -e "$titleAndLabels""set grid; set title 'Best'; plot  \"""$fileName""\"  using 1:3 smooth unique;"

# 	titleAndLabels="set terminal png; set output '""plots_""$fileName""/mean"".png'; set xlabel 'Data set'; set ylabel 'Estimation error'; set yrange [0:180];"
# 	# gnuplot -e "$titleAndLabels""set grid; set title 'MeanAll'; plot \"""$fileName""\" using 1:((column(2)+column(3)+column(4)+column(5)+column(6)+column(7))/6) smooth unique;"
# 	gnuplot -e "$titleAndLabels""set grid; set title 'MeanAll'; plot \"""$fileName""\" using 1:((column(2)+column(3))/2) smooth unique;"	


# 	# gnuplot -e "$titleAndLabels""set grid; plot \"""$fileName""\" using 1:6 smooth unique; pause -1; "
# 	# gnuplot -e "$titleAndLabels""set grid; plot  \"""$fileName""\" using 1:2 smooth unique, \"resultsAllNombreRaroDiscardDay.sigma4.6.txt\" using 1:7 smooth unique; pause -1; "
done



# mkdir "plots_""$fileName"






## probar tambien con dia enterooooo


# , \"Least Squares\" using 1:2 with line; pause -1;"