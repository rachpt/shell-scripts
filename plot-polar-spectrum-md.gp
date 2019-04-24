#!/usr/bin/env gnuplot
# Author: rachpt
# Date: 2019-04-24

#文件夹名
foldername=system("basename `pwd`")
#------------select-theta--------------#
system sprintf("rm -f %s_tsurff_polar.dat", foldername)
## print only the lines for theta=pi/2 and blank lines between the data blocks
system "awk '$3==1.5707963267948966 || $0==\"\" {print $0}' $(ls -v tsurff-polar*) > tsurff-polar.dat"
## erase superfluous blank lines
system "cat -s tsurff-polar.dat > temp"
## copy line for phi=0 to the end of a data block
system sprintf("awk '$4==0 { line=$0 }; $0==\"\" { $0 = $0 line \"\\n\" }; { print $0 }' temp > %s_tsurff_polar.dat", foldername)
system "rm -f temp" 
#------------select-theta--------------#
reset
set term x11 enhanced

set output foldername."_polar_spectrum.png"
# 图片大小
set term png size 1300,1200
set size square

# 设置 color bar
set palette defined ( 0 0 0 0, 0.1667 0 0 1, 0.5 1 1 0, 1 1 0 0 )

# Heaviside function
theta(x)=(x<0)?0.0:1.0

set xlabel "momentum $x$-direction"
set ylabel "momentum $y$-direction"

set mapping cylindrical
set pm3d map

# 最大动量值，需要修改
lim=1.0

set xrange [-lim:lim]
set yrange [-lim:lim]
set tmargin  at screen 0.95
set bmargin  at screen 0.1
set lmargin at screen 0.1
set rmargin at screen 0.9

# gnuplot expects: theta, z, r
splot sprintf("%s_tsurff_polar.dat", foldername) u 4:($5)*(theta(lim-$2)):2 w pm3d t foldername

set output
