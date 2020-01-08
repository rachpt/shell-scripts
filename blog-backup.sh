#!/bin/bash

# 备份 博客

total=5
blog='/home/rachpt/blog/'
bak_dir='/home/backups/Blog/'
#-----------------------------------------#
if [[ `ls $bak_dir|wc -w` -gt $total ]]; then
  # 清理旧文件
  del_file="${bak_dir%/}/`ls -rt "$bak_dir"|head -1`"
  [[ -f $del_file ]] && \rm -f "$del_file"
fi

name="blog_$(date '+%Y-%m-%d_%H:%M:%S').tar.gz"
blog="${blog%/}"
tar -czf "${bak_dir%/}/${name}" --directory="${blog/${blog##*/}}" "${blog##*/}"
#-----------------------------------------#

