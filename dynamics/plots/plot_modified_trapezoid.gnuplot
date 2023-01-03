set term png size 600, 1800
set output 'plots/out/modified_trapezoid.png'
set multiplot layout 3,1

plot "data/modified_trapezoid.txt" using 1:2 with lines title 'R'
plot "data/modified_trapezoid.txt" using 1:3 with lines title 'V'
plot "data/modified_trapezoid.txt" using 1:4 with lines title 'A'

unset multiplot
