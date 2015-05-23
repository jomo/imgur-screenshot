The _**Imgur-Screenshot**_ uploader for Linux/OS X from [imgur.com/apps](https://imgur.com/apps)<br>

# Imgur-Screenshot

0. select area of your screen
0. The screenshot is uploaded to [imgur](https://imgur.com)

![screenshot gif](https://i.imgur.com/ozAFCyW.gif)


Features
----
* Upload screenshot or image file
* Use any screenshot tool
* Edit image before uploading
* Upload anonymously or to your imgur account
* Copy link to clipboard
* Open uploaded image
* Delete image from disk after upload
* Filenames, links and **deletion links** are stored
* Automatically delete images after specified time
* Get notifications about updates

The edit feature is very interesting for automization with something like [ImageMagick](http://www.imagemagick.org/script/index.php), or to quickly add notes.

Installation
----

Clone the repo and check if you have all dependencies installed:

```Bash
imgur-screenshot --check
```

That's it.  
Bind the script to a hotkey or add it to your $PATH for quick access ;)

**Enjoy!**

Usage
----
```bash
imgur-screenshot [[-c | --connect] | --check | [-v | --version] | [-h | --help]] | [[-o | --open=true|false] [-e | --edit=true|false] [-l | --login=true|false] [[-a <album_title> | --album <album_title>] | [-A <album_id> | --album_id <album_id>]] [-k | --keep_file=true|false] [-d <s> | --auto-delete <s>] [file ...]]
```

| short    | command                 | description                                             |
| :----    | :---------------------- | :------------------------------------------------------ |
| -h       | --help                  | Show help, exit                                         |
| -v       | --version               | Print current version, exit                             |
|          | --check                 | Check if all dependencies are installed, exit           |
| -c       | --connect               | Show connected imgur account, exit                      |
| -o       | --open=true\|false      | override *open* config <br> -o is equal to --open=true  |
| -e       | --edit=true\|false      | override *edit* config <br> -e is equal to --edit=true  |
| -l       | --login=true\|false     | override *login* config <br> -lis equal to --login=true |
| -a       | --album \<album_title\> | Create new album and upload there                       |
| -A       | --album_id \<album_id\> | override *album_id* config                              |
| -k       | --keep_file=true\|false | override *keep_file* config                             |
| -d \<s\> | --auto-delete \<s\>     | automatically delete image after `s` seconds            |
| -u       | --update                | check for updates, exit                                 |
|          | *file* ...              | instead of uploading a screenshot, upload *file*        |

### Uploading a screenshot

All you need to do is simply run `imgur-screenshot`.

### Uploading a screenshot to your account

```bash
imgur-screenshot --connect # shows you which account you're connected to
imgur-screenshot -l
```

---

_Making a selection:_<br>
![Selection](https://i.imgur.com/3G7BmdV.png)<br>


Dependencies
----

(Most are probably pre-installed)<br>
**Tip:** Use [--check](#Installation) to see what's missing.

* curl
* grep
* **Linux only:**
* libnotify-bin
* scrot
* xclip <i>(needed for `copy_url`)</i>
* **OS X only:**
* [terminal-notifier](https://github.com/alloy/terminal-notifier) *or* [growlnotify](http://growl.info/downloads#generaldownloads)


OS support
----

This will not work on Windows. (maybe with cygwin?)<br>
I have successfully tested this on Ubuntu and OS X.<br>
If this won't work on your OS, [create a new issue](https://github.com/jomo/imgur-screenshot/issues/new?title=add+support+for+_______&body=required+steps+to+make+it+work+on+______:).


Config
----

Config options are explained below.

The default config can be overridden at `~/.config/imgur-screenshot/settings.conf`:

```bash
imgur_anon_key="486690f872c678126a2c09a9e196ce1b"
imgur_icon_path="$HOME/Pictures/imgur.png"
imgur_acct_key=""
imgur_secret=""
login="false"
album_title=""
album_id=""
credentials_file="$HOME/.config/imgur-screenshot/credentials.conf"
file_name_format="imgur-%Y_%m_%d-%H:%M:%S.png" # when using scrot, must end with .png!
file_dir="$HOME/Pictures"
upload_connect_timeout="5"
upload_timeout="120"
upload_retries="1"
screenshot_select_command="scrot -s %img" # OS X: "screencapture -i %img"
screenshot_window_command="scrot %img" # OS X: "screencapture -iWa %img"
edit_command="gimp %img"
edit="false"
exit_on_selection_fail="true"
edit_on_selection_fail="false"
exit_on_album_creation_fail="true"
open_command="xdg-open %url" # OS X: "open %url"
open="true"
log_file="$HOME/.imgur-screenshot.log"
copy_url="true"
keep_file="true"
check_update="true"
```

* imgur_anon_key

  > The imgur API key used for anonymous upload. Don't change this unless you have [a valid key](http://api.imgur.com/#register)

* imgur_acct_key

  > The imgur API key used to upload to your account.

* imgur_secret

  > The imgur API secret. Don't change this unless you have [a valid secret](http://api.imgur.com/#register) and would like to upload to your account.

* imgur_icon_path

  > The path to the imgur favicon file ([download here](https://imgur.com/favicon.ico)).<br>
  Has to be a file in your file system, links do not work.<br>
  ![example](https://imgur.com/favicon.ico) Will be shown as icon for notifications.

* login

  > If set to true, the script will try to upload to your account

* album

  > If set, the script will try to create a new album and upload to that specific album on your account (requires login)
* album_id

  > If set, the script will try to upload to that specific album on your account (requires login)

* credentials_file

  > The file used to store your account credentials

* save_file

  > If set to false, the file will be deleted after upload.

* file_name_format

  > The format used for saved screenshots. [more info](http://www.manpages.info/linux/date.1.html)

* file_dir

  > Optional. The path to the directory where you want your images saved.

* upload_connect_timeout

  > Maximum time in seconds until the connection to imgur should be established.

* upload_timeout

  > Maximum time the whole upload procedure may take.

* upload_retries

  > Amount of retries that will be done if the upload failed.

* screenshot_select_command

  > Command to create a selective screenshot and save it to `%img`

* screenshot_window_command

  > Command to grab the active window and save it to `%img`
  > On debian, you can use `scrot -u %img` to capture the active window instead of the whole screen
  > _(Used when selective screenshot cannot be taken, see [#1](https://github.com/jomo/imgur-screenshot/issues/1))_
* edit

  > If set to true, make use of edit_command

* edit_command

  > An executable that is run *before* the image is uploaded.<br>
  > The image will be uploaded when the program exits.<br>
  > `%img` is replaced with the image's filename.

* exit_on_selection_fail

  > If set to false and a selective screenshot [can't be taken](https://github.com/jomo/imgur-screenshot/issues/1), take a full screen shot instead.

* edit_on_selection_fail

  > When *exit_on_selection_fail* is *false* and the selective screenshot fails, open the (full screen) image with edit_command.

* exit_on_album_creation_fail

  > If set to false upload images even if the album creation failed.

* open_command

  > An executable that is run *after* the image was uploaded.<br>
  > `%img` is replaced with the image's filename.<br>
  > `%url` is replaced with the image's URL.

* open

  > If set to true, open url after image uploaded.

* log_file

  > The path to the logfile.<br>
  > The logfile contains filenames, URLs and errors.

* auto_delete

  > Number of seconds after which the image will be automatically deleted.
  > Leave empty to disable

* copy_url

  > If set to true, the image URL will be copied to clipboard.

* keep_file

  > If set to false, the file will be deleted. Only deletes screenshots.

* check_update

  > If set to true, it will check for updates _after_ the upload.
  > This will not apply the update, just notify you if there's a new version.


Note
----

The screenshot will be taken **after** the selection has been made. This could be annoying if you want to capture something quickly and _then_ want to select an area. I might implement this as a FutureFeature™ when I find a decent way to capture the whole screen, display the shot in full screen and then crop it to a selection.

Troubleshooting
----

If you get a notification like

> **Something went wrong :(<br>**
> Information logged to /foo/bar/logfile.log

This probably means that `scrot -s`/`screencapture -i` was unable to make a selective screenshot.

* You pressed the <kbd>any</kbd> key during selection
* (OS X / screencapture) you didn't make a selection or pressed Esc.
  * **Note**: This is a bug which I have reported to Apple. It's fixed in OS X Yosemite
* (Linux / scrot) `sleep 0.1` in the script didn't help. Try increasing the value
  * **Note**: A short sleep is required, otherwise scrot handles the hotkey you're using for imgur-screenshot as <kbd>any</kbd> key to cancel the selection
* You don't have permission to write the file
* One of the dependencies is not installed
* You don't have your display plugged in (wrong terminal?) >_<
* ?? - run `scrot -s`/`screencapture -i` directly and check the outcome

Contribute
----

* Report [issues](https://github.com/jomo/imgur-screenshot/issues)
* Submit feature request
* Make a pull request
* Buy me a beer: [`1jomojdTww1vnNwvseLrKgTENZoojQ3Um`](https://tinyurl.com/jomo-imgur)
