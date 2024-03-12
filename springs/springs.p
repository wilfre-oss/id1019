set title ""

set xlabel "n"
set ylabel "time in us"

set xtics nomirror
set ytics nomirror

set grid

set terminal epslatex color colortext
set output 'springs.tex'
plot "springs.dat" u 1:2 with lines