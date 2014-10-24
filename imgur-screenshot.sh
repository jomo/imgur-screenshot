#!/bin/bash
# https://github.com/jomo/imgur-screenshot
# https://imgur.com/apps

function is_mac() {
  uname | grep -q "Darwin"
}

### IMGUR-SCREENSHOT DEFAULT CONFIG ####

imgur_anon_key="486690f872c678126a2c09a9e196ce1b"
imgur_icon_path="$HOME/Pictures/imgur.png"

imgur_acct_key=""
imgur_secret=""
login="false"
credentials_file="$HOME/.config/imgur-screenshot/credentials.conf"

file_name_format="imgur-%Y_%m_%d-%H:%M:%S.png" # when using scrot, must end with .png!
file_dir="$HOME/Pictures"

upload_connect_timeout="5"
upload_timeout="120"
upload_retries="1"

if is_mac; then
  screenshot_select_command="screencapture -i %img"
  screenshot_window_command="screencapture -iWa %img"
  open_command="open %url"
else
  screenshot_select_command="scrot -s %img"
  screenshot_window_command="scrot %img"
  open_command="xdg-open %url"
fi

edit_command="gimp %img"
edit="false"
edit_on_selection_fail="false"

log_file="$HOME/.imgur-screenshot.log"

copy_url="true"
keep_file="true"
check_update="true"

############## END CONFIG ##############

# You can override the config in ~/.config/imgur-screenshot/settings.conf
settings_path="$HOME/.config/imgur-screenshot/settings.conf"
if [ -f "$settings_path" ]; then
  source "$settings_path"
fi

# dependencie check
if [ "$1" = "--check" ]; then
  (which grep &>/dev/null && echo "OK: found grep") || echo "ERROR: grep not found"
  if is_mac; then
    if which growlnotify &>/dev/null; then
      echo "OK: found growlnotify"
    elif which terminal-notifier &>/dev/null; then
      echo "OK: found terminal-notifier"
    else
      echo "ERROR: growlnotify nor terminal-notifier found"
    fi
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
    if which growlnotify &>/dev/null; then
      growlnotify  --icon "$imgur_icon_path" --iconpath "$imgur_icon_path" --title "$2" --message "$3"
    else
      terminal-notifier -appIcon "$imgur_icon_path" -contentImage "$imgur_icon_path" -title "imgur: $2" -message "$3"
    fi
  else
    if [ "$1" = "error" ]; then
      notify-send -a ImgurScreenshot -u critical -c "im.error" -i "$imgur_icon_path" -t 500 "imgur: $2" "$3"
    else
      notify-send -a ImgurScreenshot -u low -c "transfer.complete" -i "$imgur_icon_path" -t 500 "imgur: $2" "$3"
    fi
  fi
}

function take_screenshot() {
  echo "Please select area"
  is_mac || sleep 0.1 # https://bbs.archlinux.org/viewtopic.php?pid=1246173#p1246173

  screenshot_select_command=${screenshot_select_command/\%img/$1}
  screenshot_window_command=${screenshot_window_command/\%img/$1}

  shot_err="$($screenshot_select_command &>/dev/null)" #takes a screenshot with selection
  if [ "$?" != "0" ]; then
    if [ "$shot_err" == "giblib error: no image grabbed" ]; then # scrot specific
      echo "You cancelled the selection. Exiting."
      exit 1
    else
      echo "$shot_err" >&2
      echo "Couldn't make selective shot (mouse trapped?)."
      echo "Trying to grab active window instead."
      if ! ($screenshot_window_command &>/dev/null); then
        echo "Error for image '$1': '$shot_err'. For more information visit https://github.com/jomo/imgur-screenshot#troubleshooting" >> "$log_file"
        echo "Error for image '$1': '$shot_err'. For more information visit https://github.com/jomo/imgur-screenshot#troubleshooting"
        notify error "Something went wrong :(" "Information has been logged"
        exit 1
      fi
      if "$edit_on_selection_fail" = "true"; then
        edit="true"
      fi
    fi
  fi
}

function check_for_update() {
  # exit non-zero on HTTP error, output only the body (no stats) but output errors, follow redirects, output everything to stdout
  remote_version="$(curl -fsSL --stderr - https://raw.githubusercontent.com/jomo/imgur-screenshot/master/.version.txt)"
  if [ "$?" -eq "0" ]; then
    if [ ! "$current_version" = "$remote_version" ] && [ ! -z "$current_version" ] && [ ! -z "$remote_version" ]; then
      echo "Update found!"
      echo "Version $remote_version is available (You have $current_version)"
      notify ok "Update found" "Version $remote_version is available (You have $current_version). https://github.com/jomo/imgur-screenshot"
      echo "Check https://github.com/jomo/imgur-screenshot for more info."
    elif [ -z "$current_version" ] || [ -z "$remote_version" ]; then
      echo "Invalid empty version string"
      echo "Current (local) version: '$current_version'"
      echo "Latest (remote) version: '$remote_version'"
    else
      echo "Version $current_version is up to date."
    fi
  else
    echo "Failed to check for latest version: $remote_version"
  fi
}

function check_oauth2_client_secrets() {
  if [ -z "$imgur_acct_key" ] || [ -z "$imgur_secret" ]; then
    echo "In order to upload to your account, register a new application at:"
    echo "https://api.imgur.com/oauth2/addclient"
    echo "Then, fill out the imgur_acct_key (client ID) and imgur_secret in your config."
    exit 1
  fi
}

function load_access_token() {
  token_expire_time=0
  # check for saved access_token and its expiration date
  if [ -f "$credentials_file" ]; then
    source "$credentials_file"
  fi
  current_time="$(date +%s)"
  preemptive_refresh_time="$((10*60))"
  expired="$((current_time > (token_expire_time - preemptive_refresh_time)))"
  if [ ! -z "$refresh_token" ]; then
    # token already set
    if [ ! "$expired" -eq "0" ]; then
      # token expired
      refresh_access_token "$credentials_file"
    fi
  else
    acquire_access_token "$credentials_file"
  fi
}

function acquire_access_token() {
  check_oauth2_client_secrets
  # prompt for a PIN
  authorize_url="https://api.imgur.com/oauth2/authorize?client_id=$imgur_acct_key&response_type=pin"
  echo "Go to $authorize_url and grant access to this application."
  read -p "Enter the PIN: " imgur_pin

  if [ -z "$imgur_pin" ]; then
    echo "PIN not entered, exiting"
    exit 1
  fi

  # exchange the PIN for access token and refresh token
  response="$(curl -s \
    -F "client_id=$imgur_acct_key" \
    -F "client_secret=$imgur_secret" \
    -F "grant_type=pin" \
    -F "pin=$imgur_pin" \
    https://api.imgur.com/oauth2/token)"
  save_access_token "$response" "$1"
}

function refresh_access_token() {
  check_oauth2_client_secrets
  # exchange the refresh token for access_token and refresh_token
  response="$(curl -s -F "client_id=$imgur_acct_key" -F "client_secret=$imgur_secret" -F "grant_type=refresh_token" -F "refresh_token=$refresh_token" https://api.imgur.com/oauth2/token)"
  if [ ! "$?" -eq "0" ]; then
    # curl failed
    echo "Error: Couldn't get access token from 'https://api.imgur.com/oauth2/token'"
    exit 1
  fi
  save_access_token "$response" "$1"
}

function save_access_token() {
  if ! grep -q "access_token" <<<"$1"; then
    # server did not send access_token
    echo "Error: Something is wrong with your credentials:"
    echo "$1"
    exit 1
  fi

  access_token="$(egrep -o 'access_token":".*"' <<<"$1" | cut -d '"' -f 3)"
  refresh_token="$(egrep -o 'refresh_token":".*"' <<<"$1" | cut -d '"' -f 3)"
  expires_in="$(egrep -o 'expires_in":".*"' <<<"$1" | cut -d '"' -f 3)"
  token_expire_time=$((`date +%s`+expires_in))

  # create dir if not exist
  mkdir -p "$(dirname "$2")" 2>/dev/null
  touch "$2" && chmod 600 "$2"
  cat <<EOF > "$2"
access_token="$access_token"
refresh_token="$refresh_token"
token_expire_time="$token_expire_time"
EOF
}

function fetch_account_info() {
  response="$(curl -s -H "Authorization: Bearer $access_token" https://api.imgur.com/3/account/me.xml)"
  account_url="$(echo $response | egrep -o "<url>.*</url>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
  echo "Connected to https://$account_url.imgur.com"
}

function upload_authenticated_image() {
  echo "Uploading '$1'..."
  response="$(curl --connect-timeout "$upload_connect_timeout" -m "$upload_timeout" --retry "$upload_retries" -s -F "image=@$1" -H "Authorization: Bearer $access_token" https://api.imgur.com/3/image.xml)"
  # imgur response contains success="1" when successful
  if [[ "$response" == *"success=\"1\""* ]]; then
    # cutting the url from the xml response
    img_url="$(echo $response | egrep -o "<link>.*</link>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    deletehash="$(echo $response | egrep -o "<deletehash>.*</deletehash>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    del_url="https://imgur.com/delete/$deletehash"
    handle_upload_success "$img_url" "$del_url" "$1"
  else # upload failed
    err_msg="$(echo $response | egrep -o "<error>.*</error>" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    handle_upload_error "$err_msg" "$1"
  fi
}

function upload_anonymous_image() {
  echo "Uploading '$1'..."
  response="$(curl --connect-timeout "$upload_connect_timeout" -m "$upload_timeout" --retry "$upload_retries" -s -F "image=@$1" -F "key=$imgur_anon_key" https://imgur.com/api/upload.xml)"

  # imgur response contains stat="ok" when successful
  if [[ "$response" == *"stat=\"ok\""*  ]]; then
    # cutting the url from the xml response
    img_url="$(egrep -o "<original_image>.*</original_image>" <<<"$response" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    del_url="$(egrep -o "<delete_page>.*</delete_page>" <<<"$response" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    handle_upload_success "$img_url" "$del_url" "$1"
  else # upload failed
    err_msg="$(egrep -o "<error_msg>.*</error_msg>" <<<"$response" | cut -d ">" -f 2 | cut -d "<" -f 1)"
    handle_upload_error "$err_msg" "$1"
  fi
}

function handle_upload_success() {
  echo "image  link: $1"
  echo "delete link: $2"

  if [ "$copy_url" = "true" ]; then
    if is_mac; then
      echo -n "$1" | pbcopy
    else
      echo -n "$1" | xclip -selection clipboard
    fi
    echo "URL copied to clipboard"
  fi

  # print to log file: image link, image location, delete link
  echo -e "$1\t$3\t$2" >> "$log_file"

  notify ok "Upload done!" "$1"

  if [ ! -z "$open_command" ]; then
    open_command=${open_command/\%url/$1}
    open_command=${open_command/\%img/$2}
    echo "Opening '$open_command'"
    $open_command
  fi
}

function handle_upload_error() {
  error="Upload failed: \"$1\""
  echo "$error"
  echo -e "Error\t$2\t$error" >> "$log_file"
  notify error "Upload failed :(" "$1"
}

# determine the script's location
which="$(which "$0")"
origin_dir="$( dirname "$(readlink "$which" || echo "$which")")"

# get the current version from .version.txt
if [ -f "$origin_dir/.version.txt" ]; then
  current_version="$(cat "$origin_dir/.version.txt")"
  if [ -z "$current_version" ]; then
    echo "Something went wrong while getting the current version from '$origin_dir/.version.txt'"
  fi
else
  current_version="?!?"
  echo "Unable to find file '$origin_dir/.version.txt' - Make sure it does exist."
  echo "You can download the file from https://github.com/jomo/imgur-screenshot/"
fi

while [ $# != 0 ]
  do
  case "$1" in
  -v)
    echo "$current_version"
    exit 0
    ;;
  -e | --edit=true)
    edit="true"
    ;;
  --edit=false)
    edit="false"
    ;;
  -l | --login=true)
    login="true"
    ;;
  --login=false)
    login="false"
    ;;
  --connect)
    # connect
    load_access_token
    fetch_account_info
    exit 0
    ;;
  --keep_file=true)
    keep_file="true"
    ;;
  --keep_file=false)
    keep_file="false"
    ;;
  *)
    upload_file="$1"
    ;;
  esac
  shift
done

if [ "$login" = "true" ]; then
  # load before changing directory
  load_access_token
fi

if [ -z "$upload_file" ]; then
  cd $file_dir

  # new filename with date
  img_file="$(date +"$file_name_format")"
  take_screenshot "$img_file"
else
  # upload file instead of screenshot
  img_file="$upload_file"
fi

# get full path
img_file="$(cd "$( dirname "$img_file")" && echo "`pwd`/`basename "$img_file"`")"

# open image in editor if configured
if [ "$edit" = "true" ]; then
  edit_command=${edit_command/\%img/$img_file}
  echo "Opening editor '$edit_command'"
  if ! ($edit_command); then
    echo "Error for image '$img_file': command '$edit_command' failed, not uploading. For more information visit https://github.com/jomo/imgur-screenshot#troubleshooting" >> "$log_file"
    echo "Error for image '$img_file': command '$edit_command' failed, not uploading. For more information visit https://github.com/jomo/imgur-screenshot#troubleshooting"
    notify error "Something went wrong :(" "Information has been logged"
    exit 1
  fi
fi

# check if file exists
if [ ! -f "$img_file" ]; then
  echo "file '$img_file' doesn't exist !"
  exit 1
fi

if [ "$login" = "true" ]; then
  upload_authenticated_image "$img_file"
else
  upload_anonymous_image "$img_file"
fi

# delete file if configured
if [ "$keep_file" = "false" ] && [ -z "$1" ]; then
  echo "Deleting temp file ${file_dir}/${img_file}"
  rm -rf "$img_file"
fi


if [ "$check_update" = "true" ]; then
  check_for_update
fi
