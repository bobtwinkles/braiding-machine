set term png size 512, 512
set output 'plots/out/cam_compare.png'

set size square
set xrange [-150:150]
set yrange [-150:150]
set xtics 25
set ytics 25
plot "data/cam_points.txt"         using 3:4 with lines title "optimized", \
     "data/cam_points_tangent.txt" using 3:4 with lines title "naive", \

