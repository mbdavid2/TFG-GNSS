
strings=(
	# 'LS10Epochs'
	# 'proximaCentauri'
	'1EpochProxima'
	# 'nightHemisphere.2Epochs.cos0.2.txt'
	# 'allIPPs2Epochscos0.1.txt'
)

# Caso A: 1 epoca sola (20 samples) + 2 epocas (10 samples) pero pintando con la primera y la segunda sobrepuestas
# Caso B: 1 epoca sola (20 samples) + 2 epocas (10 samples) pero pintando con la primera y la segunda sobrepuestas

for i in "${strings[@]}"; do
    fileName="$i"
	titleAndLabels="set xlabel 'Epoch'; set ylabel 'Estimation error'; set yrange [0:180];"
	gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares'; plot  \"""$fileName""\" using 1:2 smooth unique; pause -1;"
	gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares 2 iterations'; plot  \"""$fileName""\" using 1:3 smooth unique; pause -1;"
	gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares 3 iterations'; plot  \"""$fileName""\" using 1:4 smooth unique; pause -1;"
	gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares 10 iterations'; plot  \"""$fileName""\" using 1:5 smooth unique; pause -1;"
	gnuplot -e "$titleAndLabels""set grid; set title 'Decreasing Range'; plot  \"""$fileName""\" using 1:6 smooth unique; pause -1;"


	# gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares'; plot  \"""$fileName""\" using 1:3 smooth unique, \"""$fileName""\" using 2:3 smooth unique; pause -1;"
	# gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares 2 iterations'; plot  \"""$fileName""\" using 1:4 smooth unique, \"""$fileName""\" using 2:4 smooth unique; pause -1;"
	# gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares 3 iterations'; plot  \"""$fileName""\" using 1:5 smooth unique, \"""$fileName""\" using 2:5 smooth unique; pause -1;"
	# gnuplot -e "$titleAndLabels""set grid; set title 'Least Squares 10 iterations'; plot  \"""$fileName""\" using 1:6 smooth unique, \"""$fileName""\" using 2:6 smooth unique; pause -1;"
	# gnuplot -e "$titleAndLabels""set grid; set title 'Decreasing Range'; plot  \"""$fileName""\" using 1:7 smooth unique, \"""$fileName""\" using 2:7 smooth unique; pause -1;"


	# gnuplot -e "$titleAndLabels""set grid; set title 'Decreasing Range'; plot  \"""$fileName""\" using 1:6 smooth unique; pause -1;"
	# gnuplot -e "$titleAndLabels""set grid; set title 'Best'; plot  \"""$fileName""\" using 1:2 smooth unique; pause -1;"
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