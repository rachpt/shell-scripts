#!/bin/bash 
# author: rachpt@126.com
#------settings--------#

myfolder=finshed
# use sd or ipad
compatibility=sd 

#-------maincode-------#

if [ $compatibility == "sd" ]
then
	cut="854x480"
	videorate="500k"
	audiorate="64k"
	speed="fast"
	profile="-x264-params \"profile=high:level=4.0\""
	out="480p"
	
elif [ $compatibility == "ipad" ]
then
	cut="1280x720"
	videorate="2200k"
	audiorate="128k"
	speed="slow"
	profile="-x264-params \"profile=high:level=4.2\""
	out="720p"
else
        exit
	
fi


if [ ! -d $myfolder ];then
  mkdir -p $myfolder
fi

filelist=$(find \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.ts" -o -iname "*.avi" -o -iname "*.wmv" \) -a ! -name "*_$out.mp4")
FOLDER=$(cd `dirname $0`; pwd)

for filename in $filelist

do
	tempname=${filename#*/}
	newfilename=${FOLDER}/${tempname}
	ffmpegcode="ffmpeg -i $newfilename -s $cut -c:v libx264 $profile -preset $speed -b:v $videorate"
	isempty=${filename#*.}
	isempty=${isempty%/*}

	if [ ! -d $myfolder$isempty ];then
	
  		mkdir -p $myfolder$isempty
	fi
	
	nohup $ffmpegcode -pass 1 -an -f mp4 -y /dev/null && $ffmpegcode -pass 2 -c:a aac -b:a $audiorate -strict -2 ${FOLDER}/$myfolder/${tempname%.*}_$out.mp4 >/dev/null 2>&1
	echo "nohup $ffmpegcode -pass 1 -an -f mp4 -y /dev/null && $ffmpegcode -pass 2 -c:a aac -b:a $audiorate -strict -2 ${FOLDER}/$myfolder/${tempname%.*}_$out.mp4 >/dev/null 2>&1"
done

rm -f ffmpeg2pass*
echo "finished!"
exit
