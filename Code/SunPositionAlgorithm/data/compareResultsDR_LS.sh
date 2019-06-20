# Separate the file for both cases
awk "NR>=0 && NR<=10" tmpResults.out > Decreasing\ Range
awk "NR>=11" tmpResults.out > Least\ Squares

# Error vs mean vtec
titleAndLabels="$xaxis""set title 'Estimation error and power of the flare'; set xlabel 'Mean VTEC of the epoch'; set ylabel 'Estimation error';"
gnuplot -e  "$titleAndLabels""set grid; plot \"Decreasing Range\" using 2:3 smooth unique; pause -1;"

# Estimation error
# xaxis="set xtics 1;"
titleAndLabels="$xaxis""set title 'Estimation error and power of the flare'; set xlabel 'Data set'; set ylabel 'Estimation error';"
# gnuplot -e  "$titleAndLabels""set grid; plot \"Decreasing Range\" using 1:2 with line, \"Least Squares\" using 1:2 with line; pause -1;"

# Time
titleAndLabels="set title 'Comparison of the execution time'; set xlabel 'Data set'; set ylabel 'Execution time';"
# gnuplot -e  "$titleAndLabels""set grid; plot \"Decreasing Range\" using 1:3 with line, \"Least Squares\" using 1:3 with line; pause -1;"

# titleAndLabels="set title 'Real error as a function of the Least Squares error'; set xlabel 'Least Squares error'; set ylabel 'Residual error';"
# gnuplot -e  "$titleAndLabels""set grid; plot \"LeastSquares.out\" using 3:2 with line; pause -1;"
# set yrange [0:100]; p