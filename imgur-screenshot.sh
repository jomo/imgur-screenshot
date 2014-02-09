#!/bin/bash
# https://github.com/JonApps/imgur-screenshot
# https://imgur.com/apps

############# CONFIG ############

imgur_key="486690f872c678126a2c09a9e196ce1b"
imgur_icon_path="$HOME/Pictures/imgur.png"
save_file="true"
file_prefix="imgur-"
file_dir="$HOME/Pictures"
edit_command="gimp %img"
upload_connect_timeout="5"
upload_timeout="120"
upload_retries="1"
copy_url="true"
open_command="firefox %url"
log_file="$HOME/.imgur-screenshot.log"
check_update="true"

######### END CONFIG ###########


function is_mac() {
  uname | grep -q "Darwin"
}

if [ "$1" = "check" ]; then
  (which grep &>/dev/null && echo "OK: found grep") || echo "ERROR: grep not found"
  if is_mac; then
    (which terminal-notifier &>/dev/null && echo "OK: found terminal-notifier") || echo "ERROR: terminal-notifier not found"
    (which screencapture &>/dev/null && echo "OK: found screencapture") || echo "ERROR: screencapture not found"
    (which pbcopy &>/dev/null && echo "OK: found pbcopy") || echo "ERROR: pbcopy not found"
  else
    (which notify-send &>/dev/null && echo "OK: found notify-send") || echo "ERROR: notify-send (from libnotify-bin) not found"
    (which scrot &>/dev/null && echo "OK: found scrot") || echo "ERROR: scrot not found"
    (which xclip &>/dev/null && echo "OK: found xclip") || echo "ERROR: xclip not found"
  fi
  (which curl &>/dev/null && echo "OK: found curl") || echo "ERROR: curl not found"
  exit 0
fi


# notify <'ok'|'error'> <title> <text>
function notify() {
  if is_mac; then
    terminal-notifier -title "$2" -message "$3"
  else
    if [ "$1" = "error" ]; then
      notify-send -a ImgurScreenshot -u critical -c "im.error" -i "$imgur_icon_path" -t 500 "$2" "$3"
    else
      notify-send -a ImgurScreenshot -u low -c "transfer.complete" -i "$imgur_icon_path" -t 500 "$2" "$3"
    fi
  fi
}

function take_screenshot() {
  echo "Please select area"
  is_mac || sleep 0.1 # https://bbs.archlinux.org/viewtopic.php?pid=1246173#p1246173

  if ! (scrot -s "$1" &>/dev/null || screencapture -s "$1" &>/dev/null); then #takes a screenshot with selection
    echo "Couldn't make selective shot (mouse trapped?). Trying to grab active window instead"
    if ! (scrot -u "$1" &>/dev/null || screencapture -oWa "$1" &>/dev/null); then
      echo "Error for image '$1'! For more information visit https://github.com/JonApps/imgur-screenshot#troubleshooting" >> "$log_file"
      echo "Something went wrong. Check the log."
      notify error "Something went wrong :(" "Information logged to $log_file"
      exit 1
    fi
  fi
}

function check_for_update() {
  current_version=$(cat "${origin_dir}/.version.txt")
  remote_version="$(curl -f https://raw.github.com/JonApps/imgur-screenshot/master/.version.txt 2>/dev/null)"
  if [ ! "$current_version" = "$remote_version" ] && [ ! -z "$current_version" ] && [ ! -z "$remote_version" ]; then
    echo "Update found!"
    echo "Version $remote_version is available (You have $current_version)"
    notify ok "Update found" "Version $remote_version is available (You have $current_version). https://github.com/JonApps/imgur-screenshot"
    echo "Check https://github.com/JonApps/imgur-screenshot for more info."
  else
    echo "Version $current_version is up to date."
  fi
  exit 0
}

function upload_image() {
  echo "Uploading '${1}'..."
  response=`curl --connect-timeout "$upload_connect_timeout" -m "$upload_timeout" --retry "$upload_retries" -s -F "image=@$1" -F "key=$imgur_key" https://imgur.com/api/upload.xml`

  # imgur response contains stat="ok" when successful
  if [[ "$response" == *"stat=\"ok\""*  ]]; then
    # cutting the url from the xml response
    img_url=`echo "$response" | egrep -o "<original_image>(.)*</original_image>" | egrep -o "http://i.imgur.com/[^<]*"`
    echo "$img_url"

    if [ "$copy_url" = "true" ]; then
      if is_mac; then
        echo "$img_url" | pbcopy
      else
        echo "$img_url" | xclip -selection clipboard
      fi
      echo "URL copied to clipboard"
    fi

    notify ok "Imgur: Upload done!" "$img_url"

    if [ ! -z "$open_command" ]; then
      open_command=${open_command/\%img/$1}
      open_command=${open_command/\%url/$img_url}
      echo "Opening '$open_command'"
      $open_command
    fi

  else # upload failed
    img_url="error - couldn't get image url"
    echo "Upload failed, Server response:" >> "$log_file"
    echo "$response" >> "$log_file"
    notify error "Imgur: Upload failed :(" "Information has been logged."
  fi
}

if is_mac; then
  origin_dir="$(dirname "$(readlink $0)")"
else
  origin_dir="$(dirname "$(readlink -f $0)")"
fi

if [ -z "$1" ]; then # upload file, no screenshot
  cd $file_dir

  #filename with date
  img_file="${file_prefix}$(date +"%d.%m.%Y-%H:%M:%S.png")"
  take_screenshot "$img_file"

  upload_image "$img_file"
else
  upload_image "$1"
fi

if [ ! -z "$edit_command" ]; then
  edit_command=${edit_command/\%img/$img_file}
  echo "Opening editor '$edit_command'"
  $edit_command
fi

if [ "$save_file" = "false" ]; then
  echo "Deleting temp file ${file_dir}/${img_file}"
  rm -rf "$img_file"
fi

echo -e "${img_url}\t\t${file_dir}/${img_file}" >> "$log_file"

if [ "$check_update" = "true" ]; then
  check_for_update
fi
