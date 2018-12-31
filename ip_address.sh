#!/usr/bin/env bash
# author: rachpt@126.com

if [[ $# -ge 1 ]]; then
  data=$(http GET 'http://ip.lockview.cn/default.aspx')
  pam1="$(echo "$data"|grep 'id="__VIEWSTATE"'|head -1|awk -F 'value="' '{print $2}'|sed 's!" />.*!!g')"
  pam2="$(echo "$data"|grep '__VIEWSTATEGENERATOR'|awk -F 'value="' '{print $2}'|grep -Eo '[a-zA-Z0-9]{8}|'head -1)"
  ipaddr="$(echo "$1"|grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')"
  sleep 1
  http -f POST 'http://ip.lockview.cn/default.aspx' txtSearchLine="$ipaddr" \
  btnConfirm='查询' 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:64.0) Gecko/20100101 Firefox/64.0' \
  __VIEWSTATE="$pam1" __VIEWSTATEGENERATOR="$pam2" |grep 'class="left_3"'|sed -E 's/<[^>]+>//g;s/\&nbsp;/ /g;s/^ +//g'
else
  echo '没有需要查询的ip地址！'
fi
