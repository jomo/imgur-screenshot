the _**Linux Screenshot Uploader**_ from [imgur.com/apps](https://imgur.com/apps)
# Imgur-Screenshot
_A desktop notification_<br>
![Notification](http://i.imgur.com/TVQ20qY.png)


0. select area of your desktop
0. if you want, edit the screenshot with any program _(gimp, image magick, ...)_
0. the screenshot is uplaoded [imgur](https://imgur.com)
0. the link is copied to clipboard
0. if you want, open the image (URL or file) with any program _(browser, image viewer)_

Installation
----

There isn't much to do. Check the dependencies below and run.

For fast access bind the script to a key.

**Enjoy!**

_Making a selection_<br>
![Selection](http://i.imgur.com/mZlrX16.png)<br>

Dependencies
----

These are often pre-installed on Linux

* curl
* grep
* xclip
* libnotify-bin (Linux only)
* scrot (Linux only)
* terminal-notifier (OS X only)

OS X
----

I will make the script automatically detect this when i'm not lazy.<br>
Using this on OS X is really simple. You just need to make a few changes:<br>
_(scrot and libnotify-bin are not required)_

0. Remove the `sleep` line
0. Replace `scrot` with `screencapture`
0. Install `terminal-notifier` (via brew or whatever method you like)
0. Replace anything with the format of `notify-send -foo -baz -bar "Text1" "Text2"` with `terminal-notifier -title "Text1" -message "Text2"`

That **should** be it. If you find anything else that won't work, please create a new Issue.

Config
----


You can find this at the beginning of the script.<br>
Optional configurations can be commented with a leading #.

* key

  > The imgur API key. Don't change this unless you have [a valid key](http://api.imgur.com/#register)

* ico

  > Optional. The path to the imgur favicon, [download here](https://imgur.com/favicon.ico).<br>
     ![imgur favicon](https://imgur.com/favicon.ico) Will be shown as icon for notifications.

* save

  > Optional. The path to the directory where you want your images saved.

* pre

  > Optional. A prefix that will be prepended to the filename. Filenames are in the format [%d.%m.%Y-%H:%M:%S.png](http://www.manpages.info/linux/date.1.html).

* edit

  > Optional. An executable that is run *before* the image is uploaded.<br>
  > `%img` is replaced with the image's filename.

* connect

  > Maximum time in seconds until the connection to imgur should be established.

* max

  > Maximum time the whole upload may take.

* retry

  > Amount of retries when the upload failed.

* open

  > Optional. An executable that is run *after* the image was uploaded.<br>
  > `%img` is replaced with the image's filename.<br>
  > `%url` is replaced with the image's URL.

* log

  > The path to the logfile.<br>
  > The logfile contains filenames, URLs and errors.

```bash
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
```

Note
----

On Linux, the screenshot will be taken **after** the selection has been made. This could be annoying if you want to capture something quickly and _then_ want to select an area. I might implement this as a FutureFeature™ when I find a decent way to display an image in full screen.

Troubleshooting
----

If you get a notification like

> **Something went wrong :(<br>**
> Information logged to /foo/bar/logfile.log

This means that `scrot -s`/`screencapture -s` was unable to make a selective screenshot.

* Linux: You pressed the <kbd>any</kbd> key during selection
* Linux: `sleep 0.1` in the script didn't help. Try increasing
* You don't have permission to write the file
* One of the dependencies is not installed
* You don't have your display plugged in >_<
* ?? - run `scrot -s`/`screencapture -s` directly and check the outcome
