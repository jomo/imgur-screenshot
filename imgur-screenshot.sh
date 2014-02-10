#!/bin/bash
# https://github.com/JonApps/imgur-screenshot
# https://imgur.com/apps


function is_mac() {
  uname | grep -q "Darwin"
}

# dependencie check
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
      echo "Error for image '$1'! For more information visit https://github.com/JonApps/imgur-screenshot#troubleshooting"
      notify error "Something went wrong :(" "Information has been logged"
      exit 1
    fi
  fi
}

function check_for_update() {
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
  response="$(curl --connect-timeout "$upload_connect_timeout" -m "$upload_timeout" --retry "$upload_retries" -s -F "image=@$1" -F "key=$imgur_key" https://imgur.com/api/upload.xml)"

  # imgur response contains stat="ok" when successful
  if [[ "$response" == *"stat=\"ok\""*  ]]; then
    # cutting the url from the xml response
    img_url="$(echo "$response" | egrep -o "<original_image>.*</original_image>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    del_url="$(echo "$response" | egrep -o "<delete_page>.*</delete_page>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    echo "image  link: $img_url"
    echo "delete link: $del_url"

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
    err_msg="$(echo "$response" | egrep -o "<error_msg>.*</error_msg>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    img_url="Upload failed: \"$err_msg\"" # using this for the log file
    echo "$img_url"
    notify error "Imgur: Upload failed :(" "$err_msg"
  fi
}

# determine the script's location
which="$(which "$0")"
origin_dir="$( dirname "$(readlink "$which" || echo "$which")")"


# load config file
if [ -f "$origin_dir/imgur-screenshot.config" ]; then
  source "$origin_dir/imgur-screenshot.config"
else
  echo "Unable to get config file from '$origin_dir/imgur-screenshot.config' - Make sure it does exist."
  echo "You can download the file from https://github.com/JonApps/imgur-screenshot/"
  exit 1
fi

# get the current version from .version.txt
if [ -f "$origin_dir/.version.txt" ]; then
  current_version="$(cat "$origin_dir/.version.txt")"
  if [ -z "$current_version" ]; then
    echo "Something went wrong while getting the current version from '$origin_dir/.version.txt'"
  fi
else
  current_version="?!?"
  echo "Unable to find file '$origin_dir/.version.txt' - Make sure it does exist."
  echo "You can download the file from https://github.com/JonApps/imgur-screenshot/"
fi

if [ -z "$1" ]; then
  cd $file_dir

  # new filename with date
  img_file="$(date +"$file_name_format")"
  take_screenshot "$img_file"
else
  # upload file instead of screenshot
  img_file="$1"
fi

# open image in editor if configured
if [ ! -z "$edit_command" ]; then
  edit_command=${edit_command/\%img/$img_file}
  echo "Opening editor '$edit_command'"
  $edit_command
fi

# check if file exists
if [ ! -f "$img_file" ]; then
  echo "file '$img_file' doesn't exist !"
  exit 1
fi

upload_image "$img_file"

# delete file if configured
if [ "$keep_file" = "false" ] && [ -z "$1" ]; then
  echo "Deleting temp file ${file_dir}/${img_file}"
  rm -rf "$img_file"
fi

# print to log file: image link, image location, delete link
echo -e "${img_url}\t${file_dir}/${img_file}\t${del_url}" >> "$log_file"


if [ "$check_update" = "true" ]; then
  check_for_update
fi