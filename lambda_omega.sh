#!/bin/bash
# Author: rachpt
# TODO: 激光角频率(原子单位)与对应波长(nm)的相互转化
#
if [[ "$1" =~ [\.0-9]+ ]]; then
    [[ `echo "$1 < 7"|bc` -eq 1 ]] && echo '激光波长为(单位nm)' || echo '激光角频率为(原子单位)'
    [[ "$2" =~ ^[0-9]+$ ]] && sca=$2 || sca=8
    result=`echo "scale=$sca; 2.99792457 * 10^2 / ( 6.579683921 ) / $1"|bc`
    [[ $result =~ ^\..* ]] &&  result="0$result"
    echo "$result"
else
    echo '参数：[1]激光角频率(原子单位)、或则波长(nm)，[2]小数位数(默认8位)'
fi
