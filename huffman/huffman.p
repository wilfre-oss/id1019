set title ""

set xlabel "n"
set ylabel "time in us"

set xtics nomirror
set ytics nomirror

set grid

set terminal epslatex color colortext
set output 'huffman.tex'
plot "huffman.dat" u 1:2 smooth csplines with lines, \
     "huffman.dat" u 1:3 smooth csplines with lines, \
     "encode.dat" u 1:2 smooth csplines with lines