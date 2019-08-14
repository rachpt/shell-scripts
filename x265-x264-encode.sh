#!/usr/bin/env bash
# author: rachpt@126.com
# version: 3.2
#--------settings----------#
ROOT='/home/workdir/'
# use sd or hd
compatibility="sd"
# set x264 or x264
vc="x264"
# add comment for video
mycc='powered_by_rachpt'
#--------------------------#
VIDEOS="${ROOT%/}/encoding"
OUTDIR="${ROOT%/}/output"
DONE="${ROOT%/}/done"
SCRIPTS="${ROOT%/}/scripts"
#--------------------------#

[[ -d "$OUTDIR" ]] || mkdir -p "$OUTDIR"
[[ -d "$DONE" ]] || mkdir -p "$DONE"
[[ -d "$SCRIPTS" ]] || mkdir -p "$SCRIPTS"
queues="${SCRIPTS%/}/queues.txt"

#--------pamaters---------#
if [[ $compatibility = sd ]]; then
    cut="-2:480"
    if [ $vc = "x265" ]; then
        vr="260k"  # 视频码率
    elif [ $vc = "x264" ]; then
        vr="500k"  # 视频码率
    fi
    ar="42k"  # 音频码率
    speed="fast"
    pl='4.0'
    out="480p"

elif [[ $compatibility = hd ]]; then
    cut="-2:720"
    if [ $vc = "x265" ]; then
        vr="1200k"  # 视频码率
    elif [ $vc = "x264" ]; then
        vr="2200k"  # 视频码率
    fi
    ar="128k"  # 音频码率
    speed="slow"
    pl='4.2'
    out="720p"
fi
#-------------------------------------#
[[ `ffmpeg -hide_banner -encoders|&grep -s libfdk_aac` ]] && {
  aac='libfdk_aac -profile:a aac_he_v2'
} || {
  aac='aac'
}
#-------------------------------------#
update_lists() {
  ( \cd "$VIDEOS" && \ls -1 >> "$queues" )
}
#-------------------------------------#
quality() {
  local qt
  scale="-vf scale=$cut"
  qt="$(ffmpeg -hide_banner -i "$1" 2>&1|grep -Eio '[0-9]{3,4}x[0-9]{3,4}')"
  [[ ${qt#*[xX]} -le ${cut#*:} ]] && {
    out="${qt#*[xX]}p"
    scale=''
  }
}
#----------main func------------#
main() {
  local thread="${SCRIPTS%/}/thread"
  local THREAD_num=2                      #定义进程数量  2
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
    #[[ $f ]] || break
    sed -i '$d' "$queues"
    [[ $f ]] && { name="${f%.*}";f="${VIDEOS%/}/$f"; }
    [[ -f "$f" ]] && {
      quality "$f"  # 判断是否需要缩小分辨率
      out_path="${OUTDIR%/}/${name}_${vc}_${out}.mp4"
      [[ -f "$out_path" ]] || {
      local _dir="${SCRIPTS%/}/${RANDOM}${RANDOM}"
      mkdir -p "$_dir"; cd "$_dir"
      mv "$f" "${_dir%/}/${f##*/}"
      f="${_dir%/}/${f##*/}"
	  if [[ $vc = x265 ]]; then
     (nice -19 ffmpeg -y -i "$f" -max_muxing_queue_size 9999 -metadata title="$name" \
     -metadata comment="${mycc:-Linux}" $scale -c:v libx265 -x265-params pass=1 \
     -x265-params no-info=1 -b:v $vr -an -f mp4 -hide_banner /dev/null) && (nice -19 \
     ffmpeg -y -i "$f" -max_muxing_queue_size 9999 -metadata title="$name" -metadata \
     comment="${mycc:-Linux}" -hide_banner $scale -c:v libx265 -x265-params pass=2 \
     -x265-params no-info=1 -b:v $vr -c:a $aac -b:a "$ar" -strict -2 "$out_path")

    elif [[ $vc = x264 ]]; then
     (nice -19 ffmpeg -y -i "$f" -max_muxing_queue_size 9999 -metadata title="$name" \
     -metadata comment="${mycc:-Linux}" $scale -c:v libx264 -b:v $vr -profile:v high \
     -level $pl -pass 1 -bsf:v 'filter_units=remove_types=6' -an -f mp4 -hide_banner \
     /dev/null) && (nice -19 ffmpeg -hide_banner -y -i "$f" -metadata title="$name" \
     -max_muxing_queue_size 9999 -metadata comment="${mycc:-Linux}" $scale -c:v \
     libx264 -b:v $vr -profile:v high -level $pl -bsf:v 'filter_units=remove_types=6' \
     -pass 2 -c:a $aac -b:a "$ar" -strict -2 "$out_path")

    fi; }
    \mv -f "$f" "${DONE%/}/"
    }
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
[[ -f $queues && ! -s $queues ]] && \rm "$queues" "${SCRIPTS%/}/pid"

