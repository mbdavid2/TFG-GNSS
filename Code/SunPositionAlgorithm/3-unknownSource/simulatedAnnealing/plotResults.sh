grep -v "^#" tsp.output | gawk '{print $1, $NF}' | graph -y 3300 6500 -W0 -X generation -Y distance -L "TSP - 12 southwest cities" | plot -Tps > 12-cities.eps


grep initial_city_coord tsp.output | awk '{print $2, $3}'  | graph -X "longitude (- means west)" -Y "latitude" -L "TSP - initial-order" -f 0.03 -S 1 0.1 | plot -Tps > initial-route.eps


grep final_city_coord tsp.output | gawk '{print $2, $3}' | graph -X "longitude (- means west)" -Y "latitude" -L "TSP - final-order" -f 0.03 -S 1 0.1 | plot -Tps > final-route.eps