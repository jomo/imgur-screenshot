#!/bin/bash
# https://github.com/jomo/imgur-screenshot
# https://imgur.com/tools

if [ "${1}" = "--debug" ]; then
  echo "########################################"
  echo "Enabling debug mode"
  echo "Please remove credentials before pasting"
  echo "########################################"
  echo ""
  uname -a
  for arg in ${0} "${@}"; do
    echo -n "'${arg}' "
  done
  echo -e "\n"
  shift
  set -x
fi

declare -r CURRENT_VERSION="v1.7.4"

is_mac() {
  uname | grep -q "Darwin"
}

### IMGUR-SCREENSHOT DEFAULT CONFIG ####

# You can override the config in ~/.config/imgur-screenshot/settings.conf

declare IMGUR_ANON_ID="ea6c0ef2987808e"
declare IMGUR_ICON_PATH="${HOME}/Pictures/imgur.png"

declare IMGUR_ACCT_KEY
declare IMGUR_SECRET
declare CREDENTIALS_FILE="${HOME}/.config/imgur-screenshot/credentials.conf"

declare FILE_NAME_FORMAT="imgur-%Y_%m_%d-%H:%M:%S.png" # when using scrot, must end with .png!
declare FILE_DIR="${HOME}/Pictures"

declare UPLOAD_CONNECT_TIMEOUT="5"
declare UPLOAD_TIMEOUT="120"
declare UPLOAD_RETRIES="1"

if is_mac; then
  declare SCREENSHOT_SELECT_COMMAND="screencapture -i %img"
  declare SCREENSHOT_WINDOW_COMMAND="screencapture -iWa %img"
  declare SCREENSHOT_FULL_COMMAND="screencapture %img"
  declare OPEN_COMMAND="open %url"
else
  declare SCREENSHOT_SELECT_COMMAND="scrot -s %img"
  declare SCREENSHOT_WINDOW_COMMAND="scrot %img"
  declare SCREENSHOT_FULL_COMMAND="scrot %img"
  declare OPEN_COMMAND="xdg-open %url"
fi

declare EXIT_ON_ALBUM_CREATION_FAIL="true"

declare LOG_FILE="${HOME}/.imgur-screenshot.log"

declare COPY_URL="true"
declare CHECK_UPDATE="true"


# options, can be changed via flags
declare LOGIN="false"
declare ALBUM_TITLE
declare ALBUM_ID
declare OPEN="true"
if [ "$BASH_VERSINFO" -ge "4" ]; then
  declare -u MODE="SELECT"
else
  declare MODE="SELECT"
fi
declare EDIT_COMMAND="gimp %img"
declare EDIT="false"
declare AUTO_DELETE
declare KEEP_FILE="true"

# NOTICE: if you make changes here, also edit the docs at
# https://github.com/jomo/imgur-screenshot/wiki/Config

# You can override the config in ~/.config/imgur-screenshot/settings.conf

############## END CONFIG ##############

declare -r SETTINGS_PATH="${HOME}/.config/imgur-screenshot/settings.conf"
# sourced in from $CREDENTIALS_FILE
declare ACCESS_TOKEN REFRESH_TOKEN TOKEN_EXPIRE_TIME

declare -a UPLOAD_FILES

if [ -f "${SETTINGS_PATH}" ]; then
  source "${SETTINGS_PATH}"
fi

# dependency check
if [ "${1}" = "--check" ]; then
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
notify() {
  if is_mac; then
    if which growlnotify &>/dev/null; then
      growlnotify  --icon "${IMGUR_ICON_PATH}" --iconpath "${IMGUR_ICON_PATH}" --title "${2}" --message "${3}"
    else
      terminal-notifier -appIcon "${IMGUR_ICON_PATH}" -contentImage "${IMGUR_ICON_PATH}" -title "imgur: ${2}" -message "${3}"
    fi
  else
    if [ "${1}" = "error" ]; then
      notify-send -a ImgurScreenshot -u critical -c "im.error" -i "${IMGUR_ICON_PATH}" -t 500 "imgur: ${2}" "${3}"
    else
      notify-send -a ImgurScreenshot -u low -c "transfer.complete" -i "${IMGUR_ICON_PATH}" -t 500 "imgur: ${2}" "${3}"
    fi
  fi
}

take_screenshot() {
  local cmd shot_err

  echo "Please select area"
  is_mac || sleep 0.1 # https://bbs.archlinux.org/viewtopic.php?pid=1246173#p1246173

  cmd="SCREENSHOT_${MODE}_COMMAND"
  cmd=${!cmd//\%img/${1}}

  if [ -z "$cmd" ]; then
    echo "Warning: SCREENSHOT_${MODE}_COMMAND is empty (MODE=${MODE})"
    cmd=false
  fi

  shot_err="$(${cmd} &>/dev/null)" #takes a screenshot with selection
  if [ "${?}" != "0" ]; then
    echo "Failed to take screenshot '${1}': '${shot_err}'. For more information visit https://github.com/jomo/imgur-screenshot/wiki/Troubleshooting" | tee -a "${LOG_FILE}"
    notify error "Something went wrong :(" "Information has been logged"
    exit 1
  fi
}

check_for_update() {
  local remote_version

  # exit non-zero on HTTP error, output only the body (no stats) but output errors, follow redirects, output everything to stdout
  remote_version="$(curl --compressed -fsSL --stderr - "https://api.github.com/repos/jomo/imgur-screenshot/releases" | egrep -m 1 --color 'tag_name":\s*".*"' | cut -d '"' -f 4)"
  if [ "${?}" -eq "0" ]; then
    if [ ! "${CURRENT_VERSION}" = "${remote_version}" ] && [ ! -z "${CURRENT_VERSION}" ] && [ ! -z "${remote_version}" ]; then
      echo "Update found!"
      echo "Version ${remote_version} is available (You have ${CURRENT_VERSION})"
      notify ok "Update found" "Version ${remote_version} is available (You have ${CURRENT_VERSION}). https://github.com/jomo/imgur-screenshot"
      echo "Check https://github.com/jomo/imgur-screenshot/releases/${remote_version} for more info."
    elif [ -z "${CURRENT_VERSION}" ] || [ -z "${remote_version}" ]; then
      echo "Invalid empty version string"
      echo "Current (local) version: '${CURRENT_VERSION}'"
      echo "Latest (remote) version: '${remote_version}'"
    else
      echo "Version ${CURRENT_VERSION} is up to date."
    fi
  else
    echo "Failed to check for latest version: ${remote_version}"
  fi
}

check_oauth2_client_secrets() {
  if [ -z "${IMGUR_ACCT_KEY}" ] || [ -z "${IMGUR_SECRET}" ]; then
    echo "In order to upload to your account, register a new application at:"
    echo "https://api.imgur.com/oauth2/addclient"
    echo "Select 'OAuth 2 authorization without a callback URL'"
    echo "Then, set the IMGUR_ACCT_KEY (Client ID) and IMGUR_SECRET in your config."
    exit 1
  fi
}

load_access_token() {
  local current_time preemptive_refresh_time expired

  TOKEN_EXPIRE_TIME=0
  # check for saved ACCESS_TOKEN and its expiration date
  if [ -f "${CREDENTIALS_FILE}" ]; then
    source "${CREDENTIALS_FILE}"
  fi
  current_time="$(date +%s)"
  preemptive_refresh_time="$((10*60))"
  expired="$((current_time > (TOKEN_EXPIRE_TIME - preemptive_refresh_time)))"
  if [ ! -z "${REFRESH_TOKEN}" ]; then
    # token already set
    if [ "${expired}" -eq "0" ]; then
      # token expired
      refresh_access_token "${CREDENTIALS_FILE}"
    fi
  else
    acquire_access_token "${CREDENTIALS_FILE}"
  fi
}

acquire_access_token() {
  local authorize_url imgur_pin response

  check_oauth2_client_secrets
  # prompt for a PIN
  authorize_url="https://api.imgur.com/oauth2/authorize?client_id=${IMGUR_ACCT_KEY}&response_type=pin"
  echo "Go to"
  echo "${authorize_url}"
  echo "and grant access to this application."
  read -rp "Enter the PIN: " imgur_pin

  if [ -z "${imgur_pin}" ]; then
    echo "PIN not entered, exiting"
    exit 1
  fi

  # exchange the PIN for access token and refresh token
  response="$(curl --compressed -fsSL --stderr - \
    -F "client_id=${IMGUR_ACCT_KEY}" \
    -F "client_secret=${IMGUR_SECRET}" \
    -F "grant_type=pin" \
    -F "pin=${imgur_pin}" \
    https://api.imgur.com/oauth2/token)"
  save_access_token "${response}" "${1}"
}

refresh_access_token() {
  local token_url response

  check_oauth2_client_secrets
  token_url="https://api.imgur.com/oauth2/token"
  # exchange the refresh token for ACCESS_TOKEN and REFRESH_TOKEN
  response="$(curl --compressed -fsSL --stderr - -F "client_id=${IMGUR_ACCT_KEY}" -F "client_secret=${IMGUR_SECRET}" -F "grant_type=refresh_token" -F "refresh_token=${REFRESH_TOKEN}" "${token_url}")"
  if [ ! "${?}" -eq "0" ]; then
    # curl failed
    handle_upload_error "${response}" "${token_url}"
    exit 1
  fi
  save_access_token "${response}" "${1}"
}

save_access_token() {
  local expires_in

  if ! grep -q "access_token" <<<"${1}"; then
    # server did not send access_token
    echo "Error: Something is wrong with your credentials:"
    echo "${1}"
    exit 1
  fi

  ACCESS_TOKEN="$(egrep -o 'access_token":".*"' <<<"${1}" | cut -d '"' -f 3)"
  REFRESH_TOKEN="$(egrep -o 'refresh_token":".*"' <<<"${1}" | cut -d '"' -f 3)"
  expires_in="$(egrep -o 'expires_in":[0-9]*' <<<"${1}" | cut -d ':' -f 2)"
  TOKEN_EXPIRE_TIME="$(( $(date +%s) + expires_in ))"

  # create dir if not exist
  mkdir -p "$(dirname "${2}")" 2>/dev/null
  touch "${2}" && chmod 600 "${2}"
  cat <<EOF > "${2}"
ACCESS_TOKEN="${ACCESS_TOKEN}"
REFRESH_TOKEN="${REFRESH_TOKEN}"
TOKEN_EXPIRE_TIME="${TOKEN_EXPIRE_TIME}"
EOF
}

fetch_account_info() {
  local response username

  response="$(curl --compressed --connect-timeout "${UPLOAD_CONNECT_TIMEOUT}" -m "${UPLOAD_TIMEOUT}" --retry "${UPLOAD_RETRIES}" -fsSL --stderr - -H "Authorization: Bearer ${ACCESS_TOKEN}" https://api.imgur.com/3/account/me)"
  if egrep -q '"success":\s*true' <<<"${response}"; then
    username="$(egrep -o '"url":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    echo "Logged in as ${username}."
    echo "https://${username}.imgur.com"
  else
    echo "Failed to fetch info: ${response}"
  fi
}

delete_image() {
  local response

  response="$(curl --compressed -X DELETE  -fsSL --stderr - -H "Authorization: Client-ID ${1}" "https://api.imgur.com/3/image/${2}")"
  if egrep -q '"success":\s*true' <<<"${response}"; then
    echo "Image successfully deleted (delete hash: ${2})." >> "${3}"
  else
    echo "The Image could not be deleted: ${response}." >> "${3}"
  fi
}

upload_authenticated_image() {
  local title response img_id img_ext del_id err_msg

  echo "Uploading '${1}'..."
  title="$(echo "${1}" | rev | cut -d "/" -f 1 | cut -d "." -f 2- | rev)"
  if [ -n "${ALBUM_ID}" ]; then
    response="$(curl --compressed --connect-timeout "${UPLOAD_CONNECT_TIMEOUT}" -m "${UPLOAD_TIMEOUT}" --retry "${UPLOAD_RETRIES}" -fsSL --stderr - -F "title=${title}" -F "image=@\"${1}\"" -F "album=${ALBUM_ID}" -H "Authorization: Bearer ${ACCESS_TOKEN}" https://api.imgur.com/3/image)"
  else
    response="$(curl --compressed --connect-timeout "${UPLOAD_CONNECT_TIMEOUT}" -m "${UPLOAD_TIMEOUT}" --retry "${UPLOAD_RETRIES}" -fsSL --stderr - -F "title=${title}" -F "image=@\"${1}\"" -H "Authorization: Bearer ${ACCESS_TOKEN}" https://api.imgur.com/3/image)"
  fi

  # JSON parser premium edition (not really)
  if egrep -q '"success":\s*true' <<<"${response}"; then
    img_id="$(egrep -o '"id":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    img_ext="$(egrep -o '"link":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4 | rev | cut -d "." -f 1 | rev)" # "link" itself has ugly '\/' escaping and no https!
    del_id="$(egrep -o '"deletehash":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"

    if [ ! -z "${AUTO_DELETE}" ]; then
      export -f delete_image
      echo "Deleting image in ${AUTO_DELETE} seconds."
      nohup /bin/bash -c "sleep ${AUTO_DELETE} && delete_image ${IMGUR_ANON_ID} ${del_id} ${LOG_FILE}" &
    fi

    handle_upload_success "https://i.imgur.com/${img_id}.${img_ext}" "https://imgur.com/delete/${del_id}" "${1}"
  else # upload failed
    err_msg="$(egrep -o '"error":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    test -z "${err_msg}" && err_msg="${response}"
    handle_upload_error "${err_msg}" "${1}"
  fi
}

upload_anonymous_image() {
  local title response img_id img_ext del_id err_msg

  echo "Uploading '${1}'..."
  title="$(echo "${1}" | rev | cut -d "/" -f 1 | cut -d "." -f 2- | rev)"
  if [ -n "${ALBUM_ID}" ]; then
    response="$(curl --compressed --connect-timeout "${UPLOAD_CONNECT_TIMEOUT}" -m "${UPLOAD_TIMEOUT}" --retry "${UPLOAD_RETRIES}" -fsSL --stderr - -H "Authorization: Client-ID ${IMGUR_ANON_ID}" -F "title=${title}" -F "image=@\"${1}\"" -F "album=${ALBUM_ID}" https://api.imgur.com/3/image)"
  else
    response="$(curl --compressed --connect-timeout "${UPLOAD_CONNECT_TIMEOUT}" -m "${UPLOAD_TIMEOUT}" --retry "${UPLOAD_RETRIES}" -fsSL --stderr - -H "Authorization: Client-ID ${IMGUR_ANON_ID}" -F "title=${title}" -F "image=@\"${1}\"" https://api.imgur.com/3/image)"
  fi
  # JSON parser premium edition (not really)
  if egrep -q '"success":\s*true' <<<"${response}"; then
    img_id="$(egrep -o '"id":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    img_ext="$(egrep -o '"link":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4 | rev | cut -d "." -f 1 | rev)" # "link" itself has ugly '\/' escaping and no https!
    del_id="$(egrep -o '"deletehash":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"

    if [ ! -z "${AUTO_DELETE}" ]; then
      export -f delete_image
      echo "Deleting image in ${AUTO_DELETE} seconds."
      nohup /bin/bash -c "sleep ${AUTO_DELETE} && delete_image ${IMGUR_ANON_ID} ${del_id} ${LOG_FILE}" &
    fi

    handle_upload_success "https://i.imgur.com/${img_id}.${img_ext}" "https://imgur.com/delete/${del_id}" "${1}"
  else # upload failed
    err_msg="$(egrep -o '"error":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    test -z "${err_msg}" && err_msg="${response}"
    handle_upload_error "${err_msg}" "${1}"
  fi
}

handle_upload_success() {
  local open_cmd

  echo ""
  echo "image  link: ${1}"
  echo "delete link: ${2}"

  if [ "${COPY_URL}" = "true" ] && [ -z "${ALBUM_TITLE}" ]; then
    if is_mac; then
      echo -n "${1}" | pbcopy
    else
      echo -n "${1}" | xclip -selection clipboard
    fi
    echo "URL copied to clipboard"
  fi

  # print to log file: image link, image location, delete link
  echo -e "${1}\t${3}\t${2}" >> "${LOG_FILE}"

  notify ok "Upload done!" "${1}"

  if [ ! -z "${OPEN_COMMAND}" ] && [ "${OPEN}" = "true" ]; then
    open_cmd=${OPEN_COMMAND//\%url/${1}}
    open_cmd=${open_cmd//\%img/${2}}
    echo "Opening '${open_cmd}'"
    eval "${open_cmd}"
  fi
}

handle_upload_error() {
  local error

  error="Upload failed: \"${1}\""
  echo "${error}"
  echo -e "Error\t${2}\t${error}" >> "${LOG_FILE}"
  notify error "Upload failed :(" "${1}"
}

handle_album_creation_success() {
  echo ""
  echo "Album  link: ${1}"
  echo "Delete hash: ${2}"
  echo ""

  notify ok "Album created!" "${1}"

  if [ "${COPY_URL}" = "true" ]; then
    if is_mac; then
      echo -n "${1}" | pbcopy
    else
      echo -n "${1}" | xclip -selection clipboard
    fi
    echo "URL copied to clipboard"
  fi

  # print to log file: album link, album title, delete hash
  echo -e "${1}\t\"${3}\"\t${2}" >> "${LOG_FILE}"
}

handle_album_creation_error() {
  local error

  error="Album creation failed: \"${1}\""
  echo -e "Error\t${2}\t${error}" >> "${LOG_FILE}"
  notify error "Album creation failed :(" "${1}"
  if [ ${EXIT_ON_ALBUM_CREATION_FAIL} ]; then
    exit 1
  fi
}

while [ ${#} != 0 ]; do
  case "${1}" in
  -h | --help)
    echo "usage: ${0} [--debug] [-c | --check | -v | -h | -u]"
    echo "       ${0} [--debug] [option]... [file]..."
    echo ""
    echo "      --debug                  Enable debugging, must be first option"
    echo "  -h, --help                   Show this help, exit"
    echo "  -v, --version                Show current version, exit"
    echo "      --check                  Check if all dependencies are installed, exit"
    echo "  -c, --connect                Show connected imgur account, exit"
    echo "  -o, --open <true|false>      Override 'OPEN' config"
    echo "  -e, --edit <true|false>      Override 'EDIT' config"
    echo "  -i, --edit-command <command> Override 'EDIT_COMMAND' config (include '%img'), sets --edit 'true'"
    echo "  -l, --login <true|false>     Override 'LOGIN' config"
    echo "  -a, --album <album_title>    Create new album and upload there"
    echo "  -A, --album-id <album_id>    Override 'ALBUM_ID' config"
    echo "  -k, --keep-file <true|false> Override 'KEEP_FILE' config"
    echo "  -d, --auto-delete <s>        Automatically delete image after <s> seconds"
    echo "  -u, --update                 Check for updates, exit"
    echo "  file                         Upload file instead of taking a screenshot"
    exit 0;;
  -v | --version)
    echo "${CURRENT_VERSION}"
    exit 0;;
  -s | --select)
    MODE="SELECT"
    shift;;
  -w | --window)
    MODE="WINDOW"
    shift;;
  -f | --full)
    MODE="FULL"
    shift;;
  -o | --open)
    OPEN="${2}"
    shift 2;;
  -e | --edit)
    EDIT="${2}"
    shift 2;;
  -i | --edit-command)
    EDIT_COMMAND="${2}"
    EDIT="true"
    shift 2;;
  -l | --login)
    LOGIN="${2}"
    shift 2;;
  -c | --connect)
    load_access_token
    fetch_account_info
    exit 0;;
  -a | --album)
    ALBUM_TITLE="${2}"
    shift 2;;
  -A | --album-id)
    ALBUM_ID="${2}"
    shift 2;;
  -k | --keep-file)
    KEEP_FILE="${2}"
    shift 2;;
  -d | --auto-delete)
    AUTO_DELETE="${2}"
    shift 2;;
  -u | --update)
    check_for_update
    exit 0;;
  *)
    UPLOAD_FILES=("${@}")
    break;;
  esac
done

if [ "${LOGIN}" = "true" ]; then
  # load before changing directory
  load_access_token
fi


if [ -n "${ALBUM_TITLE}" ]; then
  if [ "${LOGIN}" = "true" ]; then
    response="$(curl -fsSL --stderr - \
      -F "title=${ALBUM_TITLE}" \
      -H "Authorization: Bearer ${ACCESS_TOKEN}" \
      https://api.imgur.com/3/album)"
  else
    response="$(curl -fsSL --stderr - \
      -F "title=${ALBUM_TITLE}" \
      -H "Authorization: Client-ID ${IMGUR_ANON_ID}" \
      https://api.imgur.com/3/album)"
  fi
  if egrep -q '"success":\s*true' <<<"${response}"; then # Album creation successful
    echo "Album '${ALBUM_TITLE}' successfully created"
    ALBUM_ID="$(egrep -o '"id":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    del_id="$(egrep -o '"deletehash":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    handle_album_creation_success "http://imgur.com/a/${ALBUM_ID}" "${del_id}" "${ALBUM_TITLE}"

    if [ "${LOGIN}" = "false" ]; then
      ALBUM_ID="${del_id}"
    fi
  else # Album creation failed
    err_msg="$(egrep -o '"error":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    test -z "${err_msg}" && err_msg="${response}"
    handle_album_creation_error "${err_msg}" "${ALBUM_TITLE}"
  fi
fi

if [ -z "${UPLOAD_FILES}" ]; then
  UPLOAD_FILES[0]=""
fi

for upload_file in "${UPLOAD_FILES[@]}"; do

  if [ -z "${upload_file}" ]; then
    cd "${FILE_DIR}" || exit 1

    # new filename with date
    img_file="$(date +"${FILE_NAME_FORMAT}")"
    take_screenshot "${img_file}"
  else
    # upload file instead of screenshot
    img_file="${upload_file}"
  fi

  # get full path
  img_file="$(cd "$( dirname "${img_file}")" && echo "$(pwd)/$(basename "${img_file}")")"

  # check if file exists
  if [ ! -f "${img_file}" ]; then
    echo "file '${img_file}' doesn't exist !"
    exit 1
  fi

  # open image in editor if configured
  if [ "${EDIT}" = "true" ]; then
    edit_cmd=${EDIT_COMMAND//\%img/${img_file}}
    echo "Opening editor '${edit_cmd}'"
    if ! (eval "${edit_cmd}"); then
      echo "Error for image '${img_file}': command '${edit_cmd}' failed, not uploading. For more information visit https://github.com/jomo/imgur-screenshot/wiki/Troubleshooting" | tee -a "${LOG_FILE}"
      notify error "Something went wrong :(" "Information has been logged"
      exit 1
    fi
  fi

  if [ "${LOGIN}" = "true" ]; then
    upload_authenticated_image "${img_file}"
  else
    upload_anonymous_image "${img_file}"
  fi

  # delete file if configured
  if [ "${KEEP_FILE}" = "false" ] && [ -z "${1}" ]; then
    echo "Deleting temp file ${FILE_DIR}/${img_file}"
    rm -rf "${img_file}"
  fi

  echo ""
done


if [ "${CHECK_UPDATE}" = "true" ]; then
  check_for_update
fi