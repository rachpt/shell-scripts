#!/bin/bash
# Author: rachpt
#
# TODO: 修改视频音频速度，并封装线性调节字幕
#
mkdir encode
cd work_path

# 视频音频 1.7 倍速
IFS=$'\n';time for i in $(ls -1 *.mp4);do echo "$i"; ffmpeg -i "$i" -r 30 -c:v libx264 -preset fast -filter_complex "[0:v]setpts=10/17 *PTS[v];[0:a]atempo=1.7[a]" -map "[v]" -map "[a]" "../encode/$i" -y 2>/dev/null; done

# 字幕线性缩放器，匹配视频 1.7 倍速
IFS=$'\n';time for i_i in `ls -1 *.srt`;do echo "$i_i";for i in `grep -Eo '([0-9]{2}:){2}[0-9]{2},[0-9]{3}' "$i_i"` ;do a=${i:0:2};b=${i:3:2};c=${i:6:2};d=${i:9:3};total=`echo "scale=0;((($a*60+$b)*60+$c)*1000+$d)/1.7"|bc`;e=$((total % 1000));f=$((total / 1000));g=$((f % 60));h=$((f / 60));x=$((h % 60));y=$((h / 60)) ;j=`printf "%02d:%02d:%02d,%03d\n" $y $x $g $e`;sed -i "s/$i/$j/" "$i_i"; done ;done


# 封装字幕
IFS=$'\n';time for i in `ls -1 *.mp4`; do if [[ -f "${i%.*}.srt" ]]; then echo "$i";ffmpeg -i "$i" -i "${i%.*}.srt"  -metadata comment="made by rach" -c:s mov_text -c:v copy -c:a copy "../done/$i" -y 2>/dev/null; rm "$i" "${i%.*}.srt"; else mv "$i" "../done/$i";fi;done
