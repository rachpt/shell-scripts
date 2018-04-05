#!/bin/bash 
# author: rachpt@126.com
# version: 1.0
#------settings--------#

# use sd or ipad
compatibility="sd"
# set x264 or x264
videoencode="x265"
# default out folder
myfolder=$videoencode
# add comment for video
mycomment=made_by_Linux_OS

#-------maincode-------#

if [ $compatibility == "sd" ]
	then
		cut="-s 854x480"
		if [ $videoencode == "x265" ]; then
				videorate="-b:v 260k"
			elif [ $videoencode == "x264" ]; then
				videorate="-b:v 500k"
		fi
		audiorate="-b:a 42k"
		speed="-preset fast"
		profile="-x264-params \"profile=high:level=4.0\""
		out="480p"
		
	elif [ $compatibility == "ipad" ]
	then
		cut="-s 1280x720"
		if [ $videoencode == "x265" ]; then
				videorate="-b:v 1200k"
			elif [ $videoencode == "x264" ]; then
				videorate="-b:v 2200k"
		fi		
		audiorate="-b:a 128k"
		speed="-preset slow"
		profile="-x264-params \"profile=high:level=4.2\""
		out="720p"
	else
	        exit
	
fi


if [ ! -d $myfolder ];then
  mkdir -p $myfolder
fi

filelist=$(find \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.ts" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.wmv" \) -a ! -name "*_$out.mp4")
FOLDER=$(cd `dirname $0`; pwd)

IFS_OLD=$IFS
IFS=$'\n'

for filename in $filelist

do
	tempname=${filename#*/};
	newfilename=${FOLDER}/${tempname};
	
	if [ $tempname == */* ]; then
		videoname=${filename##*/};
		else
		videoname=$tempname
	fi
	
	videoname="-metadata title=${videoname%.*} -metadata comment=$mycomment";
	if [ $videoencode == "x265" ]; then
			ffmpegcode="ffmpeg -y -i \"$newfilename\" $videoname $cut -c:v lib$videoencode -r 24 $speed $videorate";
			setpass="-x265-params pass=";
		elif [ $videoencode == "x264" ]; then
			ffmpegcode="ffmpeg -y -i \"$newfilename\" $videoname $cut -c:v lib$videoencode -r 24 $profile $speed $videorate";
			setpass="-pass ";
	fi
	isempty=${filename#*.};
	isempty=${isempty%/*};

	if [ ! -d $myfolder$isempty ]; then
	
  		mkdir -p $myfolder$isempty;
	fi
	
	outfilepath=${FOLDER}/$myfolder/${tempname%.*}_${videoencode}_${out}.mp4
	
	if [ -f "$outfilepath" ]; then
  		continue;
	fi
	
	nohup $ffmpegcode ${setpass}1 -an -f mp4 -y /dev/null && $ffmpegcode ${setpass}2 -c:a aac $audiorate -strict -2 \"$outfilepath\" >/dev/null 2>&1

done

IFS=$IFS_OLD


rm -f ffmpeg2pass*
rm -f x265_2pass.log*
echo "finished!"
exit
