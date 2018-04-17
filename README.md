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

## unzip.sh

解压 脚本所在目录以及子目录k中的所有 `rar` 文件，保持路径结构，解压到 `un_zip` 文件夹。

## resize-pic.sh

配合 `unzip.sh` 使用 `ImageMagick` 批量压制缩小图片。
`-resize 800 -quality 60 ` 核心部分。

