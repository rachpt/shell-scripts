#!/usr/bin/env bash
# author: rachpt@126.com
# version: 3.1
#--------settings----------#
VIDEOS="~/workdir/encoding"
OUTDIR="~/workdir/x265"
DONE="~/workdir/done"
SCRIPTS="~/workdir/scripts"  # this file's path

# use sd or ipad
compatibility="sd"
# set x264 or x264
videoencode="x265"
# add comment for video
my_comment='Powered by rachpt'

#-------------------------#

[[ -d "$OUTDIR" ]] || mkdir -p "$OUTDIR"
[[ -d "$DONE" ]] || mkdir -p "$DONE"
[[ -d "$SCRIPTS" ]] || mkdir -p "$SCRIPTS"
queues="${SCRIPTS%/}/queues.txt"

#--------pamaters---------#
if [ $compatibility = "sd" ]; then
    cut="-2:480"
    if [ $videoencode = "x265" ]; then
        videorate="260k"
    elif [ $videoencode = "x264" ]; then
        videorate="500k"
    fi
    audiorate="42k"
    speed="fast"
    profile="-x264-params 'profile=high:level=4.0'"
    out="480p"

elif [ $compatibility = "ipad" ]; then
    cut="-2:720"
    if [ $videoencode = "x265" ]; then
        videorate="1200k"
    elif [ $videoencode = "x264" ]; then
        videorate="2200k"
    fi
    audiorate="128k"
    speed="slow"
    profile="-x264-params 'profile=high:level=4.2'"
    out="720p"
fi
#-------------------------------------#
hasfdk="$([[ `ffmpeg -encoders|&grep -s libfdk_aac` ]] && echo yes|| echo no)"
#-------------------------------------#
update_lists() {
  ( \cd "$VIDEOS" && \ls -1 >> "$queues" )
}

#----------main func------------#
main() {
  local thread="${SCRIPTS%/}/thread"
  local THREAD_num=3                      #定义进程数量  3  !
  [[ -a "$thread" ]] && \rm -f "$thread"  #若存在先删除
  mkfifo "$thread"                        #创建fifo型文件用于计数
  exec 9<> "$thread"
  #向fd9文件中写回车，有多少个进程就写多少个
  for (( i=0;i<$THREAD_num;i++ )); do
    echo -ne "\n" 1>&9
  done

  while [[ $(\ls "$VIDEOS"|wc -w) -ne 0 ]]; do
    sleep 3
    [[ -f "${SCRIPTS%/}/quit" ]] && exit;
    read -u 9   #read一次，就减去fd9中一个回车
   (
    [[ -s "$queues" ]] || update_lists
    #----------st
    one_file="$(tail -1 "$queues")"
    sed -i '$d' "$queues"
    [[ $one_file ]] && { name="${one_file%.*}";one_file="${VIDEOS%/}/$one_file"; }
    [[ -f "$one_file" ]] && {
      out_path="${OUTDIR%/}/${name}_${videoencode}_${out}.mp4"
      [[ -f "$out_path" ]] || {
      local _dir="${SCRIPTS%/}/${RANDOM}${RANDOM}"
      mkdir -p "$_dir"; cd "$_dir"
      mv "$one_file" "${_dir%/}/${one_file##*/}"
      one_file="${_dir%/}/${one_file##*/}"
	  if [[ $videoencode == x265 ]]; then
     (nice -19 ffmpeg -y -i "$one_file" -metadata title="$name" \
     -metadata comment="$my_comment" -vf scale=$cut -c:v libx265 -x265-params \
     pass=1 -r 24 -b:v $videorate -an -f mp4 /dev/null ) && ( nice -19 \
     ffmpeg -y -i "$one_file" -metadata title="$name" -metadata \
     comment="$my_comment" -vf scale=$cut -c:v libx265 -x265-params pass=2 -r 24 \
     -b:v $videorate -c:a \
     `[[ $hasfdk = yes ]] && echo 'libfdk_aac -profile:a aac_he_v2' || echo aac` \
     -b:a "$audiorate" -strict -2 "$out_path" )

    elif [ "$videoencode" = "x264" ]; then
     (nice -19 ffmpeg -y -i "$one_file" -metadata title="$name" -metadata \
     comment="$my_comment" -vf scale=$cut -c:v libx264 -r 24 -b:v $videorate -pass 1 \
     -an -f mp4 /dev/null ) && ( nice -19 ffmpeg -y -i "$one_file" -metadata \
     title="$name" -metadata comment="$my_comment" -vf scale=$cut -c:v libx264 -r 24 \
     -b:v $videorate -pass 2 -c:a \
     `[[ $hasfdk = yes ]] && echo 'libfdk_aac -profile:a aac_he_v2' || echo aac` \
     -b:a "$audiorate" -strict -2 "$out_path" )

    fi; }
    }
    \mv -f "$one_file" "${DONE%/}/"
    [[ -d "$_dir" ]] && \rm -rf "$_dir"
    unset _dir
    #----------ed
      echo -ne "\n" 1>&9  #子进程结束时，向fd9追加一个回车符，补充
   )&
  done
  wait    #等待所有后台子进程结束
  \rm -f "$thread"
}
#------------------------#
rm -f nohup.out
main
[[ -s "$queues" ]] || \rm "$queues"

