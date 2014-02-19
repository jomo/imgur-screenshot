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

function check_oauth2_client_secrets() {
  if [ -z "$imgur_key" ] || [ -z "$imgur_secret" ]; then
    echo "In order to upload to your account, register a new application at:"
    echo "https://api.imgur.com/oauth2/addclient"
    echo "Then, fill out the imgur_key and imgur_secret config with your client ID and client secret."
    exit 1
  fi
}

function load_access_token() {
  token_expire_time=0
  # check for saved access_token and its expiration date
  config_path="$origin_dir/imgur-credentials.config"
  if [ -f "$config_path" ]; then
    source "$config_path"
  fi
  current_time=`date +%s`
  preemptive_refresh_time=$((10*60))
  expired=$((current_time > (token_expire_time - preemptive_refresh_time)))
  if [ ! -z "$access_token" ] && [ "$expired" -eq "0" ]; then
    return
  fi
  if [ ! -z "$refresh_token" ]; then
    refresh_access_token "$config_path"
    return
  fi
  acquire_access_token "$config_path"
}

function acquire_access_token() {
  check_oauth2_client_secrets
  # prompt for a PIN number
  authorize_url="https://api.imgur.com/oauth2/authorize?client_id=$imgur_key&response_type=pin"
  echo "Go to"
  echo $authorize_url
  echo "and grant access to this application."
  read -p "Enter the PIN number: " pin_number

  # exchange the PIN number for access token and refresh token
  response="$(curl -s -F "client_id=$imgur_key" -F "client_secret=$imgur_secret" -F "grant_type=pin" -F "pin=$pin_number" https://api.imgur.com/oauth2/token)"
  save_access_token "$response" "$1"
}

function refresh_access_token() {
  check_oauth2_client_secrets
  # exchange the refresh token for access_token and refresh_token
  response="$(curl -s -F "client_id=$imgur_key" -F "client_secret=$imgur_secret" -F "grant_type=refresh_token" -F "refresh_token=$refresh_token" https://api.imgur.com/oauth2/token)"
  save_access_token "$response" "$1"
}

function save_access_token() {
  access_token="$(echo $1 | egrep -o 'access_token":".*"' | cut -d '"' -f 3)"
  refresh_token="$(echo $1 | egrep -o 'refresh_token":".*"' | cut -d '"' -f 3)"
  expires_in="$(echo $1 | egrep -o 'expires_in":".*"' | cut -d '"' -f 3)"
  token_expire_time=$((`date +%s`+expires_in))
  cat <<EOF > "$2"
access_token=$access_token
refresh_token=$refresh_token
token_expire_time=$token_expire_time
EOF
}

function fetch_account_info() {
  response="$(curl -s -H "Authorization: Bearer $access_token" https://api.imgur.com/3/account/me.xml)"
  account_url="$(echo $response | egrep -o "<url>.*</url>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
  echo "Connected to $account_url.imgur.com"
}

function upload_authenticated_image() {
  echo "Uploading '${1}'..."
  response="$(curl --connect-timeout "$upload_connect_timeout" -m "$upload_timeout" --retry "$upload_retries" -s -F "image=@$1" -H "Authorization: Bearer $access_token" https://api.imgur.com/3/image.xml)"
  # imgur response contains success="1" when successful
  if [[ "$response" == *"success=\"1\""* ]]; then
    # cutting the url from the xml response
    img_url="$(echo $response | egrep -o "<link>.*</link>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    deletehash="$(echo $response | egrep -o "<deletehash>.*</deletehash>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    handle_upload_success "$1" "$img_url" "http://imgur.com/delete/$deletehash"
  else # upload failed
    err_msg="$(echo $response | egrep -o "<error>.*</error>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    handle_upload_error "$err_msg"
  fi
}

function upload_anonymous_image() {
  echo "Uploading '${1}'..."
  response="$(curl --connect-timeout "$upload_connect_timeout" -m "$upload_timeout" --retry "$upload_retries" -s -F "image=@$1" -F "key=$imgur_key" https://imgur.com/api/upload.xml)"

  # imgur response contains stat="ok" when successful
  if [[ "$response" == *"stat=\"ok\""*  ]]; then
    # cutting the url from the xml response
    img_url="$(echo "$response" | egrep -o "<original_image>.*</original_image>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    del_url="$(echo "$response" | egrep -o "<delete_page>.*</delete_page>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    handle_upload_success "$1" "$img_url" "$del_url"
  else # upload failed
    err_msg="$(echo "$response" | egrep -o "<error_msg>.*</error_msg>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    handle_upload_error "$err_msg"
  fi
}

function handle_upload_success() {
  echo "image  link: $2"
  echo "delete link: $3"

  if [ "$copy_url" = "true" ]; then
    if is_mac; then
      echo "$1" | pbcopy
    else
      echo "$1" | xclip -selection clipboard
    fi
    echo "URL copied to clipboard"
  fi

  notify ok "Imgur: Upload done!" "$1"

  if [ ! -z "$open_command" ]; then
    open_command=${open_command/\%img/$1}
    open_command=${open_command/\%url/$2}
    echo "Opening '$open_command'"
    $open_command
  fi
}

function handle_upload_error() {
  img_url="Upload failed: \"$1\"" # using this for the log file
  echo "$img_url"
  notify error "Imgur: Upload failed :(" "$1"
}

# determine the script's location
which="$(which "$0")"
origin_dir="$( dirname "$(readlink "$which" || echo "$which")")"


# load config file
if [ -f "$origin_dir/imgur-screenshot.config" ]; then
  source "$origin_dir/imgur-screenshot.config"
else
  echo "Unable to get config file from '$origin_dir/imgur-screenshot.config' - Creating file for you..."
  cat > "$origin_dir/imgur-screenshot.config" <<"EOF"
### IMGUR-SCREENSHOT CONFIG ####

imgur_key="486690f872c678126a2c09a9e196ce1b"
imgur_secret=""
imgur_icon_path="$HOME/Pictures/imgur.png"

logmein="false"

file_name_format="imgur-%Y_%m_%d-%H:%M:%S.png"
file_dir="$HOME/Pictures"

upload_connect_timeout="5"
upload_timeout="120"
upload_retries="1"

#edit_command="gimp %img"
open_command="firefox %url"

log_file="$HOME/.imgur-screenshot.log"

copy_url="true"
keep_file="true"
check_update="true"

######### END CONFIG ###########
EOF
  echo "File '$origin_dir/imgur-screenshot.config' created."
  echo "Try again ;)"
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

if [ "$1" = "connect" ]; then
  load_access_token
  fetch_account_info
  exit 0
fi

if [ "$logmein" = "true" ]; then
  # load before changing directory
  load_access_token
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

if [ "$logmein" = "true" ]; then
  upload_authenticated_image "$img_file"
else
  upload_anonymous_image "$img_file"
fi

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
