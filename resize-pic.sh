#!/bin/bash 

if [ ! -d re_size ];then
  mkdir -p re_size
fi

filelist=$(find  -iname "*.jpg")
FOLDER=$(cd `dirname $0`; pwd)


for filename in $filelist

do  
	tempname=${filename#*.}
	newfilename=${FOLDER}${tempname}
	
	
	if [ ! -d re_size${tempname%/*} ];then
  		mkdir -p re_size${tempname%/*}
	fi
	
	convert $newfilename -resize 800 -quality 60 ${FOLDER}/re_size${tempname} 

done 

