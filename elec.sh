#!/bin/bash
# Author: rachpt
# TODO: 激光强度(*e14 W/cm^2)与对应场强(原子单位)的相互转化
#
if [[ "$1" =~ [\.0-9]+$ ]]; then
    echo -e "\033[32m激光强度\033[0m \e[1;43m`printf "%20s" $1`\e[0m\t(\033[35m*e14\033[0m W/cm^2)"
    [[ "$2" =~ [0-9]+ ]] && sca=$2 || sca=8
    result=`echo "scale=$sca;(0.0533802681207856 * sqrt($1))/1"|bc`
    [[ $result =~ ^\..* ]] && result="0$result" || result="$result"
    [[ $result ]] &&  echo -e "\033[32m电场场强\033[0m \e[1;41m`printf "%20s" $result`\e[0m\t(原子单位)"

elif [[ "$1" =~ [\.0-9]+au$ ]]; then
    echo -e "\033[32m电场场强\033[0m \e[1;43m`printf "%20s" ${1//au}`\e[0m\t(原子单位)"
    [[ "$2" =~ [0-9]+ ]] && sca=$2 || sca=8
    result=`echo "scale=$sca;((${1//au/} / 0.0533802681207856)^2)/1"|bc`
    [[ $result =~ ^\..* ]] && result="0$result" || result="$result"
    [[ $result ]] &&  echo -e "\033[32m激光强度\033[0m \e[1;41m`printf "%20s" $result`\e[0m\t(\033[35m*e14\033[0m W/cm^2)"

else
    echo -e '参数：[1]\033[32m激光强度\033[0m(*e14 W/cm^2)、\033[32m电场场强\033[0m(原子单位 au后缀)，[2]小数位数(默认8位)'
fi
