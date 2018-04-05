#!/bin/bash 

if [ ! -d un_zip ];then
  mkdir -p un_zip
fi

filelist=$(find  -iname "*.rar")
FOLDER=$(cd `dirname $0`; pwd)

IFS_OLD=$IFS
IFS=$'\n'

for filename in $filelist

do
	tempname=${filename#*.}
	newfilename=${FOLDER}${tempname}
	unrar x -o- -y \"$newfilename\" \"${FOLDER}/un_zip/\"
	sleep 1
	
done

IFS=$IFS_OLD

exit
