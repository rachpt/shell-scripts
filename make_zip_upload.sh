#!/bin/bash 
# author: rachpt@126.com
# version: 1.4
#------settings--------#
password='mypassword'

pass="lock"

baidupcs="/opt/baidupcs/baidupcs"

uplaodPath="/压缩包_集合/XX/"

#--------zip-----------#
cd $1
FOLDER=$1
filelist=$(find \( -iname "*_x264_480p.mp4" -o -iname "*_x264_720p.mp4" -o -iname "*_x265_480p.mp4" -o -iname "*_x265_720p.mp4")

FOLDER=$(cd `dirname $0`; pwd)

IFS_OLD=$IFS
IFS=$'\n'

for filename in $filelist

do
	tempname=${filename#*/};
	newfilename=${FOLDER}/${tempname};
	zipPath=${newfilename%.*}_${pass}.zip

	zip -rP $password $zipPath $newfilename 

done 

#-------upload---------#

for filename in $filelist

do
	tempname=${filename#*/};
	newfilename=${FOLDER}/${tempname};
	zipPath=${newfilename%.*}_${pass}.zip

	$baidupsc u $zipPath $uplaodPath
	sleep 1
	rm -f $zipPath 
done 

IFS=$IFS_OLD

exit
