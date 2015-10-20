#!

taille=$1 max=$2
gnuplot -persist <<EOF
set logscale x
set xlabel "Nombre de threads"
set ylabel "Temps d'execution (en sec)"
set title "Temps d'execution en fonction du nombre de threads pour n = $taille"
set xtics (1, 2, 4, 8, 16, 32, 64, 128, 256)
plot [0.9:300][0:$max] \
	 "temps-$taille.txt" using 1:2 title "seq" with linespoints,\
	 "temps-$taille.txt" using 1:3 title "P:S::" with linespoints,\
	 "temps-$taille.txt" using 1:4 title "P:S:1:" with linespoints,\
	 "temps-$taille.txt" using 1:5 title "P:S:20:" with linespoints,\
	 "temps-$taille.txt" using 1:6 title "P:D:1:" with linespoints,\
	 "temps-$taille.txt" using 1:7 title "P:D:20:" with linespoints,\
	 "temps-$taille.txt" using 1:8 title "PFJ:S::" with linespoints,\
	 "temps-$taille.txt" using 1:9 title "PFJ:S:1:" with linespoints,\
	 "temps-$taille.txt" using 1:10 title "PFJ:S:20:" with linespoints
EOF

