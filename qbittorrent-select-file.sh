#!/usr/bin/env bash
# Author: rachpt@126.com
# Date: 2019-07-31

# 通过文件后缀批量 选择下载或者跳过 qbittorrent 中某个种子的特定文件。
# 参数交互式输入。
# qbittorrent 4.1+，API v2.2.0+，httpie 0.9.8+ 

echo 'Input url (default http://127.0.0.1:8080)'
read host
host="${host:-"http://127.0.0.1:8080"}"
filePrio="${host%/}/api/v2/torrents/filePrio"
files="${host%/}/api/v2/torrents/files?hash="

echo 'Input Cookie (SID=xxxxxx)'
read cookie
[[ "$cookie" ]] && \
cookie="Cookie:SID=${cookie#"SID=:"}"

echo 'Input tr hash'
read tr_hash
[[ ${#tr_hash} -ne 40 ]] && {
  echo "Torrent's hash is not right! again"
  read tr_hash
}

echo 'Input 后缀名：(区分大小写，多个请用|分割,比如 MP4|mp4|mkv)'
read ext


ids="$(http --pretty=format GET "${files}${tr_hash}" "$cookie"|grep '"name":'| \
  sed 's/ *"name": "//;s/",$//'|awk "BEGIN{ORS=\"|\"}/$ext/{print NR-1}")"

[[ "$ids" ]] || {
  echo 'No such files!'
  exit 1
}

echo '是下载还是跳过？(y|Y|1 下载，其他跳过)'
read yesno

case yesno in
  y|Y|1)
    commit=1 ;;
  *)
    commit=0 ;;
esac

echo '开始设置'

http -f POST "$filePrio" hash="${tr_hash}" id="${ids%|}" priority="$commit" "$cookie"


