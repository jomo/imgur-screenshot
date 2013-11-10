#!/bin/bash

#Imgur API key
key="486690f872c678126a2c09a9e196ce1b"
#Imgur favicon, for notifications
ico="$HOME/Pictures/imgur.png"
#Filename prefix
pre="imgur-"
#Image location
save="$HOME/Pictures/"
#Editor (before upload)
edit="gimp"
#Open with - May be empty
open="firefox"
#Logfile
log="$HOME/.imgur-screenshot.log"


cd "$save"
#filename with date
img="$pre`date +"%d.%m.%Y-%H:%M:%S"`.png"
echo "Please select area"
# Yea.. don't ask me why, but it fixes a weird bug.
# https://bbs.archlinux.org/viewtopic.php?pid=1246173#p1246173
sleep 0.1
scrot -s "$img" #takes a screenshot with selection
if [ ! -z "$edit" ]
  then
  echo "Opening editor $edit"
  $edit "$img"
fi
echo "Uploading $img"
response=`curl -s -F "image=@$img" -F "key=$key" https://imgur.com/api/upload.xml`
echo "Server reponse received"
#echo "$response" #debug
if [[ "$response" == *"stat=\"ok\""*  ]]
  then
  url=`echo "$response" | egrep -o "<original_image>(.)*</original_image>" | egrep -o "http://i.imgur.com/[^<]*"`
  echo "$url"
  echo "$url" | xclip -selection c
  if [ ! -z "$open" ]
    then
    echo "Opening URL with $open"
    $open "$url"
  fi
  notify-send -a ImgurScreenshot -i "$ico" -t 500 "Imgur: Upload done! $url copied to clipboard!"
else
  notify-send -a ImgurScreenshot -i "$ico" -t 500 "Imgur: Upload failed :("
fi
echo -e "$url\t\t$save$img" >> "$log"
