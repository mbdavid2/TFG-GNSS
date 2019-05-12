# gnuplot -e "set xlabel 'Mean VTEC factor'; set ylabel 'Correlation Coefficient'; set grid; plot 'orderedResultsDifferentEpochs.txt' using 1:6 with line; pause -1";

# gnuplot -e "set xlabel 'Mean VTEC factor'; set ylabel 'Correlation Coefficient'; set grid; plot 'resultsDifferentEpochs.txt' using 1:7 with line; pause -1;" # 'resultsDifferentEpochs.txt' using 1:5 with line; pause -1;"

gnuplot -e "set xlabel 'Mean VTEC factor'; set ylabel 'Ra error + Dec error'; set grid; plot 'resultsDifferentEpochsCorrectError.txt' using 1:2 with line; pause -1;" # 'resultsDifferentEpochs.txt' using 1:5 with line; pause -1;"
