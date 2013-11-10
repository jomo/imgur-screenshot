# Imgur-Screenshot

A bash script that lets you take a screenshot, select an area, (edit it), upload it to [imgur](https://imgur.com), copies the link to clipboard (and opens the link).

Move the script to somewhere in your `PATH` as `imgur-screenshot`. Create a keyboard shortcut for <kbd>Print</kbd> (or any key you like) and set it to `imgur-screenshot`.

**Enjoy!**

Dependencies
----

Most of these are installed on most *nix systems

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

````bash
#Imgur API key
key="486690f872c678126a2c09a9e196ce1b"
#Imgur favicon, for notifications
ico="$HOME/Pictures/imgur.png"
#Filename prefix
pre="imgur-"
#Image location
save="$HOME/Pictures/"
#Editor (before upload)
edit="gimp"
#Open with - May be empty
open="firefox"
#Logfile
log="$HOME/.imgur-screenshot.log"
````