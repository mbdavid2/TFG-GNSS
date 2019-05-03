# gnuplot -e "set xlabel 'Epoch'; set ylabel 'Correlation Coefficient'; set grid; plot 'orderedResultsDifferentEpochs.txt' using 1:6 with line; pause -1";

gnuplot -e "set xlabel 'Order'; set ylabel 'Correlation Coefficient'; set grid; \
plot 'resultsDifferentEpochs.txt' using 1:7 with line; pause -1";
# 'resultsDifferentEpochs.txt' using 1:5 with line