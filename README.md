# Imgur-Screenshot
_Notification_<br>
![Notification](http://i.imgur.com/TVQ20qY.png)

A bash script that

* takes a screenshot of a selected area
* (lets you edit it)
* uploads it to [imgur](https://imgur.com)
* copies the link to clipboard
* (opens the link)

Installation
----

There isn't much to do. Download and run.

Make sure you allow execution of the script:

```bash
$ chmod +x imgur-screenshot.sh
```

Move the script to somewhere in your `PATH` as `imgur-screenshot`:

```bash
$ mv imgur-screenshot.sh ~/bin/imgur-screenshot
```

That's it, you can run it:

```bash
$ imgur-screenshot
```

Or bind it to <kbd>Print</kbd> _(or whatever key you like)_ as a keyboard shortcut.

**Enjoy!**

_Making a selection_<br>
![Selection](http://i.imgur.com/mZlrX16.png)<br>

Dependencies
----

Most of these are pre-installed on many *nix systems

* scrot
* curl
* grep
* xclip
* libnotify-bin

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

The screenshot will be taken **after** the selection has been made. This could be annoying if you want to capture something quickly and _then_ want to select an area. I might implement this as a FutureFeature™ when I find a decent way to display an image in full screen.

Troubleshooting
----

If you get a notification like

> **Something went wrong :(<br>**
> Information logged to /foo/bar/logfile.log

This means that `scrot -s` failed. Try increasing `sleep 0.1` until you no longer get the error.<br>
If you get this message when you press a key while selecting, you can safely ignore this message.
