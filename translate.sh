#!/bin/bash
# Author: rachpt

# The backend of GoldenGict about translate-shell and wudao-dict.
# Html format

word__="$(echo "$1"|sed 's/-%0A/-/g;s/%0A/ /g')"

echo '<b>谷歌翻译：</b>'
echo '<br/>'
trans -e google -s auto -t zh-CN -show-original n -show-original-phonetics n -show-translation y -no-ansi -show-translation-phonetics n -show-prompt-message n -show-languages n -show-original-dictionary n -show-dictionary n -show-alternatives n "$word__"

echo '<br/>'
echo '<br/>'
c=0
for i in $word__; do
  $((c++))
done
if [ $c -eq 1 ]; then
  echo '<b>有道词典：</b>'
  echo '<br/>'
  /usr/bin/wd -s "$word__"|sed -E "s/\o33\[[0-9]{1,2}m//g;s/$/<br>/g"
fi
