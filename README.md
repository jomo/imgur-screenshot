The _**Imgur-Screenshot**_ uploader for Linux & OS X from [imgur.com/tools](https://imgur.com/tools)<br>

# Imgur-Screenshot

0. select area of your screen
0. The screenshot is uploaded to [imgur](https://imgur.com)

![screenshot gif](https://i.imgur.com/ozAFCyW.gif)


Features
----
* Upload screenshot or image files
* Very customizable
* Edit image before uploading
* Upload to your imgur account or anonymously
* Create albums
* Copy link to clipboard
* Open uploaded image
* Delete image from disk after upload
* Filename, link, and **deletion link** history is stored
* Automatically delete images after specified time
* Get notifications about updates

The edit feature can be used for automated editing with something like [ImageMagick](http://www.imagemagick.org/script/index.php), or just to quickly add notes.

Installation
----

Install via Homewbrew:
```shell
brew update && brew install imgur-screenshot
```

Clone the repo and check if you have all dependencies installed:

```shell
imgur-screenshot.sh --check
```

That's it.  
Bind the script to a hotkey or add it to your $PATH for quick access ;)

**Enjoy!**

Usage
----

> **Note:** Check out [the wiki](https://github.com/jomo/imgur-screenshot/wiki) for more!

```shell
imgur-screenshot.sh [--debug] [-c | --check | -v | -h | -u]
imgur-screenshot.sh [--debug] [optiion]... [file]...
```

| short    | command                   | description                                                                                       |
| :------- | :------------------------ | :------------------------------------------------------------------------------------------------ |
|          | --debug                   | Enable debugging. Must be the first option!<br>**Remember to remove credentials before pasting!** |
| -h       | --help                    | Show help, exit                                                                                   |
| -v       | --version                 | Print current version, exit                                                                       |
|          | --check                   | Check if all dependencies are installed, exit                                                     |
| -c       | --connect                 | Show connected imgur account, exit                                                                |
| -o       | --open <true\|false>      | override *open* config <br> -o is equal to --open true                                            |
| -e       | --edit <true\|false>      | override *edit* config <br> -e is equal to --edit true                                            |
| -l       | --login <true\|false>     | override *login* config <br> -lis equal to --login true                                           |
| -a       | --album \<album_title\>   | Create new album and upload there                                                                 |
| -A       | --album-id \<album_id\>   | override *album_id* config                                                                        |
| -k       | --keep-file <true\|false> | override *keep_file* config                                                                       |
| -d \<s\> | --auto-delete \<s\>       | automatically delete image after `s` seconds                                                      |
| -u       | --update                  | check for updates, exit                                                                           |
|          | *file* ...                | instead of uploading a screenshot, upload *file*                                                  |

### Uploading a screenshot

All you need to do is simply run `imgur-screenshot.sh`.

### Uploading a screenshot to your account

```shell
imgur-screenshot.sh --connect # shows you which account you're connected to
imgur-screenshot.sh -l
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
* [terminal-notifier](https://github.com/julienXX/terminal-notifier) *or* [growlnotify](http://growl.info/downloads#generaldownloads)


OS support
----

This will not work on Windows. (maybe with cygwin?)<br>
I have successfully tested this on Ubuntu and OS X.<br>
If this won't work on your OS, [create a new issue](https://github.com/jomo/imgur-screenshot/issues/new?title=add+support+for+_______&body=required+steps+to+make+it+work+on+______:).


Note
----

The screenshot will be taken **after** the selection has been made. This might be annoying if you want to capture something quickly and _then_ want to select an area.
However, you can take a full shot and use the edit option to crop the image before upload.


How to contribute
----

* Report [issues](https://github.com/jomo/imgur-screenshot/issues)
* Submit feature request
* Make a pull request
* Buy me a beer: `1jomojdTww1vnNwvseLrKgTENZoojQ3Um`