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
#edit="gimp"
#Open URL with...
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

if ! scrot -s "$img" #takes a screenshot with selection
  then
  echo "Error for image '$img'! Try increasing the sleep time. For more information visit https://github.com/JonApps/imgur-screenshot#troubleshooting" >> "$log"
  echo "Something went wrong."
  notify-send -a ImgurScreenshot -u critical -c "im.error" -i "$ico" -t 500 "Something went wrong :(" "Information logged to $log"
  exit 1
fi

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
  notify-send -a ImgurScreenshot -u low -c "transfer.complete" -i "$ico" -t 500 'Imgur: Upload done!' "`printf "$url\ncopied to clipboard\041"`"
else
  url="[error - couldn't get image url]"
  notify-send -a ImgurScreenshot -u critical -c "transfer.error" -i "$ico" -t 500 "Imgur: Upload failed :(" "I don't know more than that"
fi
echo -e "$url\t\t$save$img" >> "$log"
