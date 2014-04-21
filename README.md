the _**Linux Screenshot Uploader**_ (and OS X) from [imgur.com/apps](https://imgur.com/apps)<br>

# Imgur-Screenshot
_A desktop notification_<br>
![Notification](http://i.imgur.com/3DuQj9n.png)


0. select area of your screen
0. The screenshot is uploaded to [imgur](https://imgur.com)

------
------
------

## Please update your git remote path!
I have recently **changed my username from _JonApps_ to _jomo_**, please make sure to update your git remotes!
If you see a notification that looks like this, you still have the old version:

> **Update found**<br>
> Version \<html\>\<body\>You are being \<a href="http<br>
> s://raw.github.com/jomo/imgur-screenshot/"\>redi<br>
> rected\</a\>.\</body\>\</htm\l>

Just run these commands:
* SSH: `git remote set-url origin git@github.com:jomo/imgur-screenshot.git`
* HTTPS: `git remote set-url origin https://github.com/jomo/imgur-screenshot.git`

------
------
------

Features
----
* You can edit the screenshot with any program _(GUI or CLI)_ before uploading
* The link can be copied to clipboard
* Normal image files can be uploaded, too
* Upload anonymous or to your imgur account
* You can open the URL or file with any program _(browser, image viewer)_ after upload
* The screenshot can be saved or deleted from disk
* All filenames + URLs (and errors) are logged
* The program can check for updates

The edit feature is very interesting for automization with something like [ImageMagick](http://www.imagemagick.org/script/index.php), or to add notes with a GUI editor.

Installation
----

Check if you have all dependencies installed:

```Bash
imgur-screenshot --check
```

That's it. You can bind the script to a hotkey or add it (or a symlink) to your $PATH for quick access ;)

**Enjoy!**

Usage
----
```bash
imgur-screenshot [[--connect | --check | -v ] | [-e | --edit=true|false] [-l | --login=true|false] [file]]
```

* `--connect` Connect to your imgur account, exit
* `--check` Check if all dependencies are installed, exit
* `-v` Print current version, exit
* `--edit=true|false` override _edit_ config (_-e_ is _--edit=true_)
* `--login=true|false` override _login_ config (_-l_ is _--login=true_)
* `file` instead of uploading a screenshot, upload `file`

### Uploading a screenshot

All you need to do is simply run `imgur-screenshot`.

### Uploading a screenshot to your account

```bash
imgur-screenshot --connect # shows you which account you're connected to
imgur-screenshot -l
```

<hr>
_Making a selection:_<br>
![Selection](https://i.imgur.com/3G7BmdV.png)<br>


Dependencies
----

(Most are probably pre-installed)

* curl
* grep

**Linux only:**
* libnotify-bin
* scrot
* xclip <i>(needed for `copy_url`)</i>

**OS X only:**
* [terminal-notifier](https://github.com/alloy/terminal-notifier)
* screencapture
* pbcopy <i>(needed for `copy_url`)</i>

Config
----


The default config can be overridden at `~/.config/imgur-screenshot/settings.conf`:


```bash
imgur_anon_key="486690f872c678126a2c09a9e196ce1b"
imgur_acct_key=""
imgur_secret=""
imgur_icon_path="$HOME/Pictures/imgur.png"
login="false"
credentials_file="$HOME/.config/imgur-screenshot/credentials.conf"
file_name_format="imgur-%Y_%m_%d-%H:%M:%S.png"
file_dir="$HOME/Pictures"
upload_connect_timeout="5"
upload_timeout="120"
upload_retries="1"
edit_command="gimp %img"
edit="false"
open_command="firefox %url"
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

  > The path to the imgur favicon ([download here](https://imgur.com/favicon.ico)).<br>
  ![imgur favicon](https://imgur.com/favicon.ico) Will be shown as icon for notifications.

* login

  > If set to true, the script will try to upload to your account

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

* edit

  > If set to true, make use of edit_command

* edit_command

  > An executable that is run *before* the image is uploaded.<br>
  > The image will be uploaded when the program exits.<br>
  > `%img` is replaced with the image's filename.

* open_command

  > An executable that is run *after* the image was uploaded.<br>
  > `%img` is replaced with the image's filename.<br>
  > `%url` is replaced with the image's URL.

* log_file

  > The path to the logfile.<br>
  > The logfile contains filenames, URLs and errors.

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

This probably means that `scrot -s`/`screencapture -s` was unable to make a selective screenshot.

* You pressed the <kbd>any</kbd> key during selection
* (Linux) `sleep 0.1` in the script didn't help. Try increasing the value
* You don't have permission to write the file
* One of the dependencies is not installed
* You don't have your display plugged in (wrong terminal?) >_<
* ?? - run `scrot -s`/`screencapture -s` directly and check the outcome
