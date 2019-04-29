#!/bin/bash
# Author: rachpt@126.com
# Date: 2019-04-29

# 批量下载 md 文件中的 新浪图片，重命名为 `文件名-数字` 格式
# 替换md文件中的 新浪图片地址

# 批量下载图片
download_pic() {
for i in `ls -1 *.md`; do
    lists="$(grep -Eio 'https?://ws..sinaimg.[-0-9a-z/]+.jpg' "$i")"
    if [[ $lists ]]; then 
        total=`echo "$lists"|wc -l`; j=1
        while [[ $j -le $total ]]; do 
            echo ${i%.md}-$j
            picurl=`echo "$lists"|sed -n "$j p"`
            echo $picurl
            # 此处使用了 httpie，当然可以使用 crul wget 等工具
            http -d "$picurl" -o "../pic/${i%.md}-$j.jpg"
            ((j++))
        done
    fi
done
}

# 替换 url 地址。两条完全可以合在一起，为了减少意外错误，这里分开
substitute_url() {
for i in `ls -1 *.md`; do
    lists="$(grep -Eio 'https?://ws..sinaimg.[-0-9a-z/]+.jpg' "$i")"
    if [[ $lists ]]; then 
        total=`echo "$lists"|wc -l`; j=1
        while [[ $j -le $total ]]; do 
            echo ${i%.md}-$j
            picurl=`echo "$lists"|sed -n "$j p"`
            echo $picurl
            # 说明：picurl 中包含'/'，因此使用\% 作为自定义正则标识符
            # s 命令匹配部分 ![] 都需要转义，替换的不用，后一个 s 使用%分割而不是/
            # 使用 {} 限定替换范围
            sed -Ei "\%$picurl% { s/\!\[.*\]/![${i%.md}-$j.jpg]/; s%$picurl%https://raw.githubusercontent.com/rachpt/imgs/master/${i%.md}-$j.jpg%; }" "$i"
            ((j++))
        done
    fi
done
}

# 调用
download_pic
echo '若无问题 30 秒后开始替换'
echo 'Ctrl + C 强制取消替换'
sleep 30
substitute_url
echo 'Done!'

