#!/usr/bin/env bash

# Author: rachpt
# Date: 2019-7-11

# 视频时间减法实现，两个参数：
#  1，被减数；2，减数
# 格式  01:22:33.456

[[ $1 && $2 ]] || { exit -1; }

# 输入
ss1=`echo $1|awk -F '.' '{print $2}'`
hms1=`echo $1|awk -F '.' '{print $1}'`
if [[ $hms1 =~ .*:.* ]]; then
    s1=`echo $hms1|awk -F ':' '{print $NF}'`

    hm1=`echo $hms1|awk -F ':' 'NF--'`

    m1=`echo $hm1|awk '{print $NF}'`

    h1=`echo $hm1|awk 'NF--'`
    h1=`echo $h1|awk '{print $NF}'`
fi
#-------------------
ss2=`echo $2|awk -F '.' '{print $2}'`
hms2=`echo $2|awk -F '.' '{print $1}'`
if [[ $hms2 =~ .*:.* ]]; then
    s2=`echo $hms2|awk -F ':' '{print $NF}'`

    hm2=`echo $hms2|awk -F ':' 'NF--'`

    m2=`echo $hm2|awk '{print $NF}'`

    h2=`echo $hm2|awk 'NF--'`
    h2=`echo $h2|awk '{print $NF}'`
fi
# 去除前零
ss1=${ss1##0}
ss2=${ss2##0}
s1=${s1##0}
s1=${s1##0}
m1=${m1##0}
m2=${m2##0}
h2=${h2##0}
h2=${h2##0}
#-------------------
# 赋默认值
ss1=${ss1:-0}
ss2=${ss2:-0}
s1=${s1:-0}
s1=${s1:-0}
m1=${m1:-0}
m2=${m2:-0}
h2=${h2:-0}
h2=${h2:-0}
#-------------------
[[ $ss1 -ge $ss2 ]] && {
    ss3=$((ss1-ss2))
} || {
    ss3=$((ss2-ss1))
    s2=$((s2 + 1))
}

[[ $s1 -ge $s2 ]] && {
    s3=$((s1-s2))
} || {
    s3=$((s2-s1))
    m2=$((m2 + 1))
}

[[ $m1 -ge $m2 ]] && {
    m3=$((m1-m2))
} || {
    m3=$((m1-m2))
    h2=$((h2 + 1))
}

h3=$((h1-h2))
#-------------------
# 输出
if [[ $h3 ]]; then
    echo "$h3:$m3:$s3.$ss3"
elif [[ $m3 ]]; then
    echo "$m3:$s3.$ss3"
else
    echo "$s3.$ss3"
fi

