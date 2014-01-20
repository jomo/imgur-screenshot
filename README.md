the _**Linux Screenshot Uploader**_ from [imgur.com/apps](https://imgur.com/apps)<br>
_(also runs on OS X)_
# Imgur-Screenshot
_A desktop notification_<br>
![Notification](http://i.imgur.com/TVQ20qY.png)


0. select area of your screen
0. The screenshot is uploaded to [imgur](https://imgur.com)

It comes with a bunch of other features:
* You can edit the screenshot with any program _(GUI or automated)_ before uploading
* The link can be copied to clipboard
* You can open the URL or file with any program _(browser, image viewer)_ after upload
* The screenshot can be saved or deleted from disk
* All filenames + URLs (and errors) are logged
* The program can check for updates

Installation
----

0. Download
0. Run `imgur-screenshot.sh check` to check if you got all dependencies installed.
0. Done!

For fast access bind the script to a key or put it in your PATH.

**Enjoy!**

_Making a selection_<br>
![Selection](http://i.imgur.com/mZlrX16.png)<br>

Dependencies
----

These are often pre-installed on Linux

* curl
* grep
* xclip _(only needed when `copy_url` is true)_
* libnotify-bin _(Linux only)_
* scrot _(Linux only)_
* screencapture _(OS X only)_
* terminal-notifier _(OS X only)_

Config
----


You can find this at the beginning of the script.<br>
Optional configurations can be commented with a leading #.

* imgur_key

  > The imgur API key. Don't change this unless you have [a valid key](http://api.imgur.com/#register)

* imgur_icon_path

  > Optional. The path to the imgur favicon, [download here](https://imgur.com/favicon.ico).<br>
     ![imgur favicon](https://imgur.com/favicon.ico) Will be shown as icon for notifications.

* save_file

  > If set to false, the file will be deleted after upload.

* file_prefix

  > Optional. A prefix that will be prepended to the filename. Filenames are in the format [%d.%m.%Y-%H:%M:%S.png](http://www.manpages.info/linux/date.1.html).

* file_dir

  > Optional. The path to the directory where you want your images saved.

* edit_command

  > Optional. An executable that is run *before* the image is uploaded.<br>
  > `%img` is replaced with the image's filename.

* upload_connect_timeout

  > Maximum time in seconds until the connection to imgur should be established.

* upload_timeout

  > Maximum time the whole upload procedure may take.

* upload_retries

  > Amount of retries that will be done if the upload failed.

* cupy_url

  > If set to true, the image URL will be copied to clipboard.

* open_command

  > Optional. An executable that is run *after* the image was uploaded.<br>
  > `%img` is replaced with the image's filename.<br>
  > `%url` is replaced with the image's URL.

* log_file

  > The path to the logfile.<br>
  > The logfile contains filenames, URLs and errors.

* check_update

  > If set to true, it will check for updates _after_ the upload.
  > This will not apply the update, just notify you if there's a new version.

```bash
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
```

Note
----

The screenshot will be taken **after** the selection has been made. This could be annoying if you want to capture something quickly and _then_ want to select an area. I might implement this as a FutureFeature™ when I find a decent way to display an image in full screen.

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
* You don't have your display plugged in (remote?) >_<
* ?? - run `scrot -s`/`screencapture -s` directly and check the outcome
