#!/usr/bin/env bash

# Author: rachpt@126.com
# Date: 2019-11-11

# 批量上传文件至蓝奏云

#--------------------------------#
username='user-name'
password='password'
lock='test-code'      # zip password
ROOT='111111'         # lanzou root dir
delete_tmp='yes'      # 删除成功上传的分卷, yes or no

uppath='../uplaoding-lanzou'
tmpdir='../succeed-lanzou'
need_hand='../need-hand-lanzou'
#--------------------------------#
lgurl='https://up.woozooo.com/account.php'
upurl='https://pc.woozooo.com/fileup.php'
mkdirurl='https://pc.woozooo.com/doupload.php'
listurl='https://pc.woozooo.com/mydisk.php'

user_agent='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0'
#--------------------------------#
get_formhash(){
  formhash="$(http -Ib "${lgurl}?action=login" "$user_agent"|grep '"formhash"'|cut -d '"' -f6)"
}
#--------------------------------#
login(){
  get_formhash
  cookie="$(http -Ihf POST "$lgurl" action=login task=login formhash=$formhash \
   username="$username" password="$password" "$user_agent"|grep 'Set-Cookie'| \
    awk -F'[:;]' 'BEGIN{ORS=";"}{print $2}')"
  [[ $cookie ]] && cookie="Cookie:$cookie"
}


#--------------------------------#
upload(){
  # 参数：需要上传的文件路径
  local fp fn ft ext folder N
  fp="$1"; folder="${2:--1}"; N=$3
  fn="${fp##*/}"
  ext="${fn##*.}"
  case $ext in
    zip|ZIP)
      ft='application/zip';;
    7z|7Z)
      ft='application/x-7z-compressed';;
    rar|RAR)
      ft='application/octet-stream';;
    pdf|PDF)
      ft='application/pdf';;
  esac
  http --pretty=format -Ibf POST "$upurl" "$cookie" task=1 id="WU_FILE_${N:-0}" \
  folder_id=$folder name="$fn" type="$ft" upload_file@"$fp" "$user_agent"|grep '"info"'

}

#--------------------------------#
make_dir(){
  local fn pid info
  # 第一个参数 可以处理带 / 的变量。
  # 修改变量 fid 值
  fn="${1##*/}"; pid="${2:-0}"
  http --pretty=format -Ibf POST "$mkdirurl" "$cookie" task=2 parent_id=$pid \
    folder_name="$fn" "$user_agent"|grep '"info"'
  info="$(http -Ib GET "$listurl" item==files action==index folder_node==1 \
    folder_id==$pid "$cookie" "$user_agent"|grep -m1 "&folder_id=.*$fn"|\
    grep -Eio 'folder_node=[0-9]+|folder_id=[0-9]*')"
  fnode="${info/${info/folder_node=[0-9]/}/}" # 文件夹嵌套不超过 10
  fnode="${fnode/${fnode/[0-9]/}/}"

  fid="${info/${info/folder_id=[0-9]*/}/}"
  fid="${fid/${fid/[0-9]*/}/}"
  echo "fnode:[$fnode]; fid:[$fid]"
}
#--------------------------------#
split_zip(){
  local file out
  file="$1"; out="${file##*/}"
  out="${2%/}/${out/${out##*.}/}zip"
  [[ $lock ]] && {
    # 加密压缩
    zip -qjP "$lock" -rs 99m "$out" "$file" 
  } || {
    # 不加密压缩
    zip -qj -rs 99m "$out" "$file" 
  }
}

#--------------------------------#
one_large_file_loop() {
  # param 1：the file to upload
  split_zip "$1" "$uppath"
  echo ''
  # 设置上传路径 pid，子路径或是设置的根路径
  [[ `\ls -1 $uppath|wc -l` -gt 1 ]] && make_dir "${1%.*}" "$ROOT" || fid=$ROOT

  for j in `\ls -1 $uppath`;do
    # 对分卷文件再次使用 zip 容器，没有加密
    zip -qj "${uppath%/}/${j}-2c.zip" "${uppath%/}/$j"
    \rm -f "${uppath%/}/$j"
    j="${j}-2c.zip"
    echo "正在上传：${j}"
    ji=0; ji_max=3   # 失败重试 3 次 
    while [[ $ji -le $ji_max ]]; do
      uploadinfo="$(upload "${uppath%/}/${j}" "$fid" $ji)"  # core
      uploadinfo="$(echo $uploadinfo|sed 's/.*": *"//;s/",//')"
      if [[ $uploadinfo =~ .*上传成功.* ]]; then
        echo -e "  ${uploadinfo} \033[32m(◦˙▽˙◦)\033[0m `du -h "${uppath%/}/${j}"|awk '{print $1}'`"
        [[ $delete_tmp = yes ]] && {
          # 删除中间文件
          \rm -f "${uppath%/}/${j}"
        } || {
          # 移动中间文件
          \mv "${uppath%/}/${j}" "$tmpdir"; }
        break
      else
        echo -e "  ${uploadinfo} \033[31m(⋟﹏⋞)\033[0m"
      fi
      ((ji++))
      if [[ $ji -le $ji_max ]]; then
        printf '%s' "  重试($ji/$ji_max)："
        sleep $((12+ji*2))
      else
        [[ -d $need_hand ]] || mkdir -p "$need_hand"
        \mv "${uppath%/}/${j}" "$need_hand"
        echo -e "  \e[1;43m请使用浏览器手动上传\e[0m  \033[33m${need_hand%/}/${j}\033[0m"
      fi
    done
  done
}
#--------------------------------#
main_loop(){
  login  # 登录，获取Cookie
  # 创建换成路径
  if [[ $1 =~ .*/.* ]]; then
    cd "${1%/*}"
    [[ -d $uppath ]] || mkdir -p "$uppath"
    [[ $delete_tmp != yes ]] && {
      [[ -d $tmpdir ]] || mkdir -p "$tmpdir"; }
  fi
  # 处理单文件
  [[ -f $1 ]] && {
    if [[ `du -m "$1"|cut -f1` -gt 99 ]]; then
      # 体积大于 99 M，分卷
      one_large_file_loop "$1"
    else
      # 小体积，不分卷
      if [[ $1 =~ ..(pdf|PDF|rar|RAR|7z|7Z|zip|ZIP) ]]; then
        uploadinfo="$(upload "$1" "$ROOT")"
      else
        zip -qj "${1%.*}-1c.zip" "$1"
        uploadinfo="$(upload "${1%.*}-1c.zip" "$ROOT")"
      fi
      uploadinfo="$(echo $uploadinfo|sed 's/.*": *"//;s/",//')"
      if [[ $uploadinfo =~ .*上传成功.* ]]; then
        echo -e "  ${uploadinfo} \033[32m(◦˙▽˙◦)\033[0m `du -h "${uppath%/}/${j}"|awk '{print $1}'`"
        [[ -f "" ]] && \rm -f "${1%.*}-1c.zip"
      else
        echo -e "  ${uploadinfo} \033[31m(⋟﹏⋞)\033[0m\n"
        echo -e "  \e[1;43m请使用浏览器手动上传\e[0m  \033[33m${1%.*}-1c.zip\033[0m"
      fi
    fi
    }
  # 处理文件夹
  [[ -d $1 ]] && {
    cd "$1"
    workp="$PWD"
    make_dir "${workp##*/}" "$ROOT"
    ROOT="$fid"  # 子目录为新的根目录
  
    old_IFS="$IFS"; IFS=$'\n'
    for i in `ls -1`;do
      IFS="$old_IFS"
      one_large_file_loop "$i"
    done
  }
  rmdir "$uppath" &> /dev/null
}

#--------------------------------#
main_loop "$1"
#--------------------------------#

