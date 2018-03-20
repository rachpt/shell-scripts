#!/bin/bash 

#------settings--------#

myfolder=finshed
# use sd or ipad
compatibility=sd 

#-------maincode-------#

if [ $compatibility == "sd" ]
then
	cut="854x480"
	videorate="500"
	audiorate="64"
	speed="fast"
	profile="-profile:v high -level 4.0"
	out="480p"
	
elif [ $compatibility == "ipad" ]
then
	cut="1280x720"
	videorate="2200"
	audiorate="128"
	speed="slow"
	profile="-profile:v high -level 4.2"
	out="720p"
else
        exit
	
fi

ffmpegcode="ffmpeg -i $newfilename -s $cut -c:v libx264 $profile -preset $speed -b:v $videorate"


if [ ! -d $myfolder ];then
  mkdir -p $myfolder
fi

filelist=$(find \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.ts" -o -iname "*.avi" -o -iname "*.wmv" \) -a ! -name "*_$out.mp4")

for filename in $filelist

do
	tempname=${filename#*/}
	newfilename=${FOLDER}/${tempname}
	
	
	if [ ! -d re_size${tempname%/*} ];then
  		mkdir -p $myfolder/${tempname%/*}
	fi
	
	nohup $ffmpegcode -pass 1 -an -f mp4 -y /dev/null >/dev/null 2>&1 && nohup $ffmpegcode -pass 2 -c:a aac -b:a $audiorate -strict -2 ${FOLDER}/$myfolder/${tempname%.*}_$out.mp4 >/dev/null 2>&1
	
done

rm ffmpeg2pass*

exit
