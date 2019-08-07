#!/usr/bin/env bash
# author: rachpt@126.com
# version: 3.2
#--------settings----------#
ROOT='/home/workdir/'
# use sd or ipad
compatibility="sd"
# set x264 or x264
vc="x265"
# add comment for video
mycc='made-by-rachpt'
#--------------------------#
VIDEOS="${ROOT%/}/encoding"
OUTDIR="${ROOT%/}/x265"
DONE="${ROOT%/}/done"
SCRIPTS="${ROOT%/}/scripts"
#--------------------------#

[[ -d "$OUTDIR" ]] || mkdir -p "$OUTDIR"
[[ -d "$DONE" ]] || mkdir -p "$DONE"
[[ -d "$SCRIPTS" ]] || mkdir -p "$SCRIPTS"
queues="${SCRIPTS%/}/queues.txt"

#--------pamaters---------#
if [ $compatibility = "sd" ]; then
    cut="-2:480"
    if [ $vc = "x265" ]; then
        vr="300k"
    elif [ $vc = "x264" ]; then
        vr="600k"
    fi
    ar="48k"
    speed="fast"
    profile="-x264-params 'profile=high:level=4.0'"
    out="480p"

elif [ $compatibility = "ipad" ]; then
    cut="-2:720"
    if [ $vc = "x265" ]; then
        vr="1400k"
    elif [ $vc = "x264" ]; then
        vr="2300k"
    fi
    ar="128k"
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
  local THREAD_num=4                      #定义进程数量  4
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
    f="$(tail -1 "$queues")"
    [[ $f ]] || break
    sed -i '$d' "$queues"
    [[ $f ]] && { name="${f%.*}";f="${VIDEOS%/}/$f"; }
    [[ -f "$f" ]] && {
      out_path="${OUTDIR%/}/${name}_${vc}_${out}.mp4"
      [[ -f "$out_path" ]] || {
      local _dir="${SCRIPTS%/}/${RANDOM}${RANDOM}"
      mkdir -p "$_dir"; cd "$_dir"
      mv "$f" "${_dir%/}/${f##*/}"
      f="${_dir%/}/${f##*/}"
	  if [[ $vc = x265 ]]; then
     (nice -19 ffmpeg -y -i "$f" -max_muxing_queue_size 9999 -metadata title="$name" \
     -metadata comment="$mycc" -vf scale=$cut -c:v libx265 -x265-params pass=1 \
     -x265-params no-info=1 -b:v $vr -an -f mp4 -hide_banner /dev/null) && (nice -19 \
     ffmpeg -y -i "$f" -max_muxing_queue_size 9999 -metadata title="$name" -metadata \
     comment="$mycc" -vf scale=$cut -c:v libx265 -x265-params pass=2 \
     -x265-params no-info=1 -hide_banner -b:v $vr -c:a \
     `[[ $hasfdk = yes ]] && echo 'libfdk_aac -profile:a aac_he_v2' || echo aac` \
     -b:a "$ar" -strict -2 "$out_path")

    elif [[ "$vc" = x264 ]]; then
     (nice -19 ffmpeg -y -i "$f" -max_muxing_queue_size 9999 -metadata title="$name" \
     -metadata comment="$mycc" -vf scale=$cut -c:v libx264 -b:v $vr -pass 1 -bsf:v \
     'filter_units=remove_types=6' -an -f mp4 -hide_banner /dev/null ) && ( \
     nice -19 ffmpeg -hide_banner -y -i "$f" -max_muxing_queue_size 9999 \
     -metadata title="$name" -metadata comment="$mycc" -vf scale=$cut -c:v \
     libx264 -b:v $vr -pass 2 -bsf:v 'filter_units=remove_types=6' -c:a \
     `[[ $hasfdk = yes ]] && echo 'libfdk_aac -profile:a aac_he_v2' || echo aac` \
     -b:a "$ar" -strict -2 "$out_path")

    fi; }
    }
    \mv -f "$f" "${DONE%/}/"
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
echo "$$" > "${SCRIPTS%/}/pid"
[[ -f "${SCRIPTS%/}/nohup.out" ]] && echo '' > "${SCRIPTS%/}/nohup.out"
main
[[ -s "$queues" ]] || \rm "$queues" "${SCRIPTS%/}/pid"

