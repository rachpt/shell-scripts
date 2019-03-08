# shell-scripts

这里放一些常用的 shell 脚本。

## formattedOutputConstants

使用方法：

```sh
./formattedOutputConstants 'constents path 1' 'constents path 2' 'constents path 3' ...
# 支持大于 1 个弹性常数地址

```
使用该脚本后，参数文件会变成 unix 格式文本文件。

图样：

![pic](https://ws1.sinaimg.cn/large/675bda05ly1fqfri3pe06j21dw09142w.jpg)

## x265-x264-encode.sh

支持 sd 720 大小，需要自己修改 脚本 头部设置，以及 编码。

使用：
直接复制 到需要压制的视频所在文件夹，使用 `nohup  &` 模式运行脚本。
注意会将 脚本所在的所有 名字中不以 _480p.mp4（sd模式） 或者 _720p.mp4（ipad模式）结尾的视频 加入列队。 

## make_zip_upload.sh

配合  `x265-x264-encode.sh` 实现自动压制视频，并压缩打包上传百度网盘。负责压缩上传部分。

## unzip.sh

解压 脚本所在目录以及子目录k中的所有 `rar` 文件，保持路径结构，解压到 `un_zip` 文件夹。

## resize-pic.sh

配合 `unzip.sh` 使用 `ImageMagick` 批量压制缩小图片。
`-resize 800 -quality 60 ` 核心部分。

## auto_delete_torrentfile.sh

自动删除 watch-dir 中的不在 transmission 列表中的旧的（可以根据最后修改时间判断）文件/文件夹，配合 flexget ratio 选项实现自动管理删除文件。同时可以设置最小容量阈值，以确保不会爆仓。

- 支持文件名、种子文件名中包含空格。

用途，可能是 auto-seed 实现的自动清理思路。

## lambda\_omega 和 elec
效果如下图，用于快速转化

![pic](https://ws1.sinaimg.cn/large/675bda05ly1g0vdhzflqdj20ay07mjsu.jpg)
https://ws1.sinaimg.cn/large/675bda05ly1g0vdhzflqdj20ay07mjsu.jpg
