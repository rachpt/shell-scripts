#!/bin/bash
# author: rachpt@126.com
# version: 2.0
#--------settings----------#
ROOT_PATH="$(dirname "$(readlink -f "$0")")"

# use sd or ipad
compatibility="sd"
# set x264 or x264
videoencode="x265"
# add comment for video
my_comment='made_by_Linux_OS'

#--------upsettings-------#
password='mypasswd'

pass="lock"

UPLOAD_PATH="/path/"

#-------------------------#
LIST_PATH="${ROOT_PATH%/*}/list_tmp.txt"

if [ ! -d "${ROOT_PATH%/*}/done" ]; then
    mkdir "${ROOT_PATH%/*}/done"
fi

find "$ROOT_PATH" \( -iname '*.mp4' -o -iname '*.mkv' -o -iname '*.m4v' -o -iname '*.ts' -o -iname '*.mov' -o -iname '*.avi' -o -iname '*.wmv' \) -a ! -name '*0p.mp4' > "$LIST_PATH"

#--------pamaters---------#
if [ $compatibility = "sd" ]; then
    cut="854x480"
    if [ $videoencode = "x265" ]; then
        videorate="260k"
    elif [ $videoencode = "x264" ]; then
        videorate="500k"
    fi
    audiorate="42k"
    speed="fast"
    profile="-x264-params 'profile=high:level=4.0'"
    out="480p"

elif [ $compatibility = "ipad" ]; then
    cut="1280x720"
    if [ $videoencode = "x265" ]; then
        videorate="1200k"
    elif [ $videoencode = "x264" ]; then
        videorate="2200k"
    fi
    audiorate="128k"
    speed="slow"
    profile="-x264-params 'profile=high:level=4.2'"
    out="720p"
fi

#--------make zip and upload-----------#
package_file_to_zip_and_upload()
{
    if [ -s "$i" ]; then
	    zip_file="${i%.*}_${pass}.zip"
	    zip -rjqP "$password" "$zip_file" "$i"
        sleep 1
        /opt/baidupcs/baidupcs upload "$zip_file" "$UPLOAD_PATH"
        sleep 1
        rm -f "$zip_file"
    fi
}

#----------main func------------#
use_ffmpeg_encode_file()
{
    while true; do
        one_file="$(tail -1 "$LIST_PATH")"
        [ ! "$one_file" ] && break
        BASE_NAME="$(basename $one_file)"
        NAME="${BASE_NAME%.*}"

        out_file_path="${one_file%.*}_${videoencode}_${out}.mp4"

		if [ ! -f "$out_file_path" ]; then
    	    if [ "$videoencode" = "x265" ]; then
    	    ( nice -19 ffmpeg -y -i "$one_file" -metadata title="$NAME" -metadata comment="$my_comment" -s $cut -c:v libx265 -x265-params pass=1 -r 24 -b:v $videorate -an -f mp4 /dev/null ) && ( nice -19 ffmpeg -y -i "$one_file" -metadata title="$NAME" -metadata comment="$my_comment" -s $cut -c:v libx265 -x265-params pass=2 -r 24 -b:v $videorate -c:a aac -b:a "$audiorate" -strict -2 "$out_file_path" )

    	    elif [ "$videoencode" = "x264" ]; then
    	    ( nice -19 ffmpeg -y -i "$one_file" -metadata title="$NAME" -metadata comment="$my_comment" -s $cut -c:v libx264 -r 24 -b:v $videorate -pass 1 -an -f mp4 /dev/null ) && ( nice -19 ffmpeg -y -i "$one_file" -metadata title="$NAME" -metadata comment="$my_comment" -s $cut -c:v libx264 -r 24 -b:v $videorate -pass 2 -c:a aac -b:a "$audiorate" -strict -2 "$out_file_path" )

    	    fi
    	fi

        #( package_file_to_zip_and_upload "$out_file_path" ) &
        #zip_and_upload_pid=$!

        mv "$one_file" "${ROOT_PATH%/*}/done/${BASE_NAME}"

        sed -i '$d' "$LIST_PATH"
        [ ! -s "$LIST_PATH" ] && break
    done
    #wait $zip_and_upload_pid > /dev/null 2>&1
}

#-------call function----------#

use_ffmpeg_encode_file

