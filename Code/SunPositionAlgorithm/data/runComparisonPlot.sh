# Separate the file for both cases
awk "NR>=0 && NR<=10" tmpResults.out > DecreasingRange.out
awk "NR>=11" tmpResults.out > LeastSquares.out

# Estimation error
# xaxis="set xtics 1;"
titleAndLabels="$xaxis""set title 'Comparison of the estimation error'; set xlabel 'Data set'; set ylabel 'Estimation error';"
# gnuplot -e  "$titleAndLabels""set grid; plot \"DecreasingRange.out\" using 1:2 with line, \"LeastSquares\" using 1:2 with line; pause -1;"




# Time
titleAndLabels="set title 'Comparison of the execution time'; set xlabel 'Data set'; set ylabel 'Execution time';"
# gnuplot -e  "$titleAndLabels""set grid; plot \"DecreasingRange.out\" using 1:3 with line, \"LeastSquares\" using 1:4 with line; pause -1;"


# Least Squares: Real error vs Covariance error
cat LeastSquares.out > RealError
cat LeastSquares.out > ResidualError

titleAndLabels="set title 'Real error vs Least Squares error'; set xlabel 'Data set'; set ylabel 'Scaled error';"
gnuplot -e  "$titleAndLabels""set grid; plot \"RealError\" using 1:3 with line, \"ResidualError\" using 1:2 with line; pause -1;"


# titleAndLabels="set title 'Real error as a function of the Least Squares error'; set xlabel 'Least Squares error'; set ylabel 'Residual error';"
# gnuplot -e  "$titleAndLabels""set grid; plot \"LeastSquares.out\" using 3:2 with line; pause -1;"


rm RealError ResidualError

# set yrange [0:100]; p