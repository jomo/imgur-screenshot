# Imgur-Screenshot

A bash script that lets you take a screenshot, select an area, (edit it), upload it to [imgur](https://imgur.com), copies the link to clipboard (and opens the link).

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
![keyboard shortcut](http://i.imgur.com/EaCvAiR.png)

**Enjoy!**

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

Please note the configuration at the beginning of the script.
If you don't want to edit your images, just comment the `edit` option. Same for the `open` option.
[Download the imgur favicon here.](https://imgur.com/favicon.ico)

```bash
#Imgur API key
key="486690f872c678126a2c09a9e196ce1b"
#Imgur favicon, for notifications
ico="$HOME/Pictures/imgur.png"
#Filename prefix
pre="imgur-"
#Image location
save="$HOME/Pictures/"
#Editor (before upload)
#edit="gimp"
#Open URL with...
open="firefox"
#Logfile
log="$HOME/.imgur-screenshot.log"
```

Troubleshooting
----

If you get a notification like

> **Something went wrong :(<br>**
> Information logged to /foo/bar/logfile.log

This means that `scrot -s` failed. Try increasing `sleep 0.1` until you no longer get the error.

Note
----

The screenshot will be taken **after** the selection has been made. This could be annoying if you want to capture something quickly and _then_ want to select an area. I might implement this as a FutureFeature™ when I find a decent way to display an image in full screen.