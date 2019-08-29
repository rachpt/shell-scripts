#!/usr/bin/env bash
# Author: rachpt@126.com
# Date: 2019/09/29
# Y2B 视频在线转码与下载
# 使用方法:
#   bash 本脚本名 一个youtube视频详情也链接.最后会打印出下载链接.例子如下
#   ./youtube.sh 'https://www.youtube.com/watch?v=ELpwAz2EbBI'
#-----------------------------------#
url="$1"

#-----------------------------------#
ua='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0'
URL='https://www.clipconverter.cc'
clip="${URL%/}/check.php"
#-----------------------------------#
tmpdata="$(http --pretty=format -Ibf "$clip" mediaurl="$url" "$ua")"

verify="$(echo "$tmpdata"|grep '"verify":'|cut -d '"' -f4)"
server="$(echo "$tmpdata"|grep '"server":'|cut -d '"' -f4)"
videoid="$(echo "$tmpdata"|grep '"videoid":'|cut -d '"' -f4)"
filename="$(echo "$tmpdata"|grep '"filename":'|cut -d '"' -f4)"
id3_artist="$(echo "$tmpdata"|grep '"id3artist":'|cut -d '"' -f4)"
id3_title="$(echo "$tmpdata"|grep '"id3title":'|cut -d '"' -f4)"
#-----------------------------------#
tmpdata_1="$(echo "$tmpdata"|grep -C1 '(1080p)')"
size="$(echo "$tmpdata_1"|grep -Eom1 '[0-9]+')"
y_url="$(echo "$tmpdata_1"|grep -Eom1 'https?://[^"]+')"
#-----------------------------------#
[[ $filename ]] || { echo '请求失败!'; exit 1; }
#-----------------------------------#
get_hash="$(http --pretty=format -Ibf "$clip" mediaurl="$url" service='YouTube' \
  url="${y_url}|$size" filename="$filename" verify="$verify" auto='1' \
  audiochannel='2' 'id3-artist'="$id3_artist" 'id3-title'="$id3_title" \
  audiobr='128' audiovol='0' ablock='1' addon_page='none' client_urlmap='none' videoid="$videoid" \
  server="$server" timefrom-start='1' timeto-end='1' format='MP4' filetype='MP4' "$ua"|grep '"hash"')"
[[ $get_hash ]] && get_hash="$(echo "$get_hash"|cut  -d '"' -f4)"
#-------------get-statusurl---------#
statusurl="$(http --pretty=format -Ib "${URL%/}/convert/$get_hash/?ajax" "$ua"|grep 'statusurl'|cut -d '"' -f2
)"
unset downurl
while [[ ! $downurl ]]; do
  tmpstatus="$(http --pretty=format -Ib "$statusurl" "$ua")"
  echo "$tmpstatus"|grep -Eo 'step"[^,}]+'|sed 's/"//g'
  echo "$tmpstatus"|grep -Eo 'percent"[^,}]+'|sed 's/"//g'
  downurl="$(echo "$tmpstatus"|grep -Eo '"downloadurl"[^,]+'|cut -d '"' -f4| \
    sed 's/\\//g;s/http:/https:/')"
  sleep 8
done

echo "$downurl"  # 这里可以写入到文件,方便使用下载工具批量下载.
#-----------------------------------#

