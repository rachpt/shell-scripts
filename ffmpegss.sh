#!/bin/bash
# Author: rachpt@126.com
# filenane: ffmpegss.sh

# 快速剪辑视频，两个参数，视频文件，start 和 end 时间。
# 输出文件为源文件加上`-`

fm=${1/*./}
[[ $fm ]] || { echo '文件 后缀名错误！'; exit 1; }

cc='made by rachpt'

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

    ffmpeg -y -ss "$st" -i "$1" -t "$ed" -metadata title="${tt:-rach}" \
      -metadata comment="${cc:-rach}" -vcodec copy -acodec copy \
      -max_muxing_queue_size 1024 -f "$fm" "${1}-" 2>/dev/null

else
    echo '参数不匹配，参数：[文件名 start end]'
fi

