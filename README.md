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
* You can open the URL or file with any program _(browser, image viewer)_ after upload
* The screenshot can be saved or deleted from disk
* All filenames + URLs (and errors) are logged
* The program can check for updates

The edit feature is very interesting for automization with something like [ImageMagick](http://www.imagemagick.org/script/index.php), or to add notes with a GUI editor.

Installation
----

Check if you have all dependencies installed:

    imgur-screenshot.sh check

That's it. You can bind the script to a hotkey or add it (or a symlink) to your $PATH for quick access ;)

**Enjoy!**

Usage
----
Take screenshot & upload:

    imgur-screenshot.sh

Upload image file:

    imgur-screenshot.sh filename


<hr>
_Making a selection:_<br>
![Selection](http://i.imgur.com/mZlrX16.png)<br>


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
