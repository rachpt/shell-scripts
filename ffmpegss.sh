#!/usr/bin/env bash
# Author: rachpt@126.com
# filenane: ffmpegss.sh

#                         0 --------|----------|----- 
# 快速剪辑视频，三个参数，视频文件，start 和 end 时间。
# 时间格式为 1:02:34.456，可以通过播放器逐帧播放得到精确时间
# 旧文件加上`.bak`，处理后的文件名为原文件名

fm=${1/*./}
[[ $fm ]] || { echo '文件 后缀名错误！'; exit 1; }

[[ $4 ]] && cc="$4" || cc='made by rachpt'

if [[ $2 && $3 ]] && [[ $2 =~ [0-9\.:]+ ]] &&[[ $3 =~ [0-9\.:]+ ]] ; then
  [[ $2 =~ [0-9]+\.?[0-9]* ]] && st="$2"
  [[ $2 =~ [0-9]+:[0-9]+\.?[0-9]* ]] && st="$(echo "$2"|awk -F: '{print $1*60+$2}')"
  [[ $2 =~ [0-9]+:[0-9]+:[0-9]+\.?[0-9]* ]] && st=`echo "$2"|awk -F: '{print $1*60*60+$2*60+$3}'`

  [[ $3 =~ [0-9]+\.?[0-9]* ]] && ed="$3"
  [[ $3 =~ [0-9]+:[0-9]+\.?[0-9]* ]] && ed="$(echo "$3"|awk -F: '{print $1*60+$2}')"
  [[ $3 =~ [0-9]+:[0-9]+:[0-9]+\.?[0-9]* ]] && ed=`echo "$3"|awk -F: '{print $1*60*60+$2*60+$3}'`
  
  [[ $st && $ed ]] || { echo 'start end 格式错误！'; exit 1; }
  ed="`awk -v s="$st" -v e="$ed" 'BEGIN{print e-s}'`"
  tt="${1%.*}"
  # 添加 meta 信息格式
  ## -metadata title="${tt:-rach}" -metadata comment="${cc:-rach}"
  file="$1"
  mv $file ${file}.old
  ffmpeg -hide_banner -y -ss "$st" -i "${file}.old" -t "$ed" -c copy \
    -max_muxing_queue_size 2024 -f "$fm" "$file" 2>/dev/null
else
  echo '参数不匹配，参数：[文件名 start end]'
fi

