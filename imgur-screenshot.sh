#!/bin/bash

key="486690f872c678126a2c09a9e196ce1b"
ico="$HOME/Pictures/imgur.png"
pre="imgur-"
save="$HOME/Pictures/"
#edit="gimp %img"
connect="5"
max="120"
retry="1"
open="firefox %url"
log="$HOME/.imgur-screenshot.log"


if [ ! -z "$save" ]
  then
  cd "$save"
fi
#filename with date
img="$pre`date +"%d.%m.%Y-%H:%M:%S.png"`"
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
  edit=${edit/%img/$img}
  echo "Opening editor '$edit'"
  $edit
fi

echo "Uploading $img"
response=`curl --connect-timeout "$connect" -m "$max" --retry "$retry" -s -F "image=@$img" -F "key=$key" https://imgur.com/api/upload.xml`
echo "Server reponse received"
#echo "$response" #debug
if [[ "$response" == *"stat=\"ok\""*  ]]
  then
  url=`echo "$response" | egrep -o "<original_image>(.)*</original_image>" | egrep -o "http://i.imgur.com/[^<]*"`
  echo "$url"
  echo "$url" | xclip -selection c
  if [ ! -z "$open" ]
    then
    open=${open/\%img/$img}
    open=${open/\%url/$url}
    echo "Opening '$open'"
    $open
  fi
  notify-send -a ImgurScreenshot -u low -c "transfer.complete" -i "$ico" -t 500 'Imgur: Upload done!' "`printf "$url\ncopied to clipboard\041"`"
else
  url="error - couldn't get image url"
  echo "Upload failed, Server response:" >> "$url"
  echo "$response" >> "$log"
  notify-send -a ImgurScreenshot -u critical -c "transfer.error" -i "$ico" -t 500 "Imgur: Upload failed :(" "Information logged to $log"
fi
echo -e "$url\t\t$save$img" >> "$log"
