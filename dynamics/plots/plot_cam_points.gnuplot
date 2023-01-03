set term png size 2000, 2000
set output 'plots/out/cam_points.png'
set multiplot layout 2,2

set xrange [0:360]
set yrange [0:120]
set xtics 30
plot "data/cam_points.txt" using 1:2 with lines

set xrange [-150:150]
set yrange [-150:150]
set xtics 25
set ytics 25
plot "data/cam_points.txt" using 3:4 with lines, \
     "data/cam_points.txt" using 5:6 with lines, \
     "data/cam_points.txt" using 7:8 with lines, \

set xrange [0:360]
set yrange [0:120]
set xtics 30
plot "cam_points_tangent.txt" using 1:2 with lines

set xrange [-150:150]
set yrange [-150:150]
set xtics 25
set ytics 25
plot "cam_points_tangent.txt" using 3:4 with lines, \
     "cam_points_tangent.txt" using 5:6 with lines, \
     "cam_points_tangent.txt" using 7:8 with lines, \

unset multiplot
