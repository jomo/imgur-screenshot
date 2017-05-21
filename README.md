The _**Imgur-Screenshot**_ uploader for Linux & OS X from [imgur.com/tools](https://imgur.com/tools)<br>

# Imgur-Screenshot

0. select area of your screen
0. The screenshot is uploaded to [imgur](https://imgur.com)

![screenshot gif](https://i.imgur.com/ozAFCyW.gif)


## Features

* Upload screenshot or image files
* Copy link to clipboard
* Customizable configuration
* Edit image before uploading
* Upload anonymously or to an account
* Create and add to albums
* Filename, link, and **deletion link** history is stored
* Automatic image deletion
* Update notifications

The edit feature can be used for automated editing with something like [ImageMagick](http://www.imagemagick.org/script/index.php), or just to quickly add notes.

## Contributing

* Report [issues](https://github.com/jomo/imgur-screenshot/issues)
* Submit feature request
* Make a pull request
* Get imgur-screenshot on more package managers!
* Buy me a beer: BTC `1jomojdTww1vnNwvseLrKgTENZoojQ3Um`

See also: [CONTRIBUTING.md](CONTRIBUTING.md)

## Installation

### Install on Mac via Homebrew

```shell
brew update && brew install imgur-screenshot
```

### Install on ArchLinux via AUR

See the [imgur-screenshot-git](https://aur.archlinux.org/packages/imgur-screenshot-git/) package.

### Install on CentOS and Fedora via COPR

See [valdikss/imgur-screenshot](https://copr.fedorainfracloud.org/coprs/valdikss/imgur-screenshot/) on COPR.

### Install on NixOS via Nix

See [imgur-screenshot](http://hydra.nixos.org/search?query=imgur-screenshot) on Hydra.

### Install via git

```shell
git clone https://github.com/jomo/imgur-screenshot.git
```

### Download source

Alternatively, you can download `imgur-screenshot.sh` from [releases](https://github.com/jomo/imgur-screenshot/releases).  
These builds have [auto-update.patch](auto-update.patch) applied, allowing to update via `--update`.

---

To check if all dependencies are installed:

```shell
imgur-screenshot.sh --check
```

That's it.  
Bind the script to a hotkey or add it to your `$PATH` for quick access ;)

**Enjoy!**

## Usage

> **Note:** You can override the default configuration in `~/.config/imgur-screenshot/settings.conf`.  
> Check out [the wiki](https://github.com/jomo/imgur-screenshot/wiki/Config) for more!

```shell
imgur-screenshot.sh [--debug] [-c | --check | -v | -h | -u]
imgur-screenshot.sh [--debug] [optiion]... [file]...
```

| short | command                   | description                                                                                                                                                                                                        |
| :---- | :------------------------ | :---------------------------------------------------------------------------------------------------------------                                                                                                   |
|       | --debug                   | Enable debugging. Must be the first option!<br>**Remember to remove credentials before pasting!**                                                                                                                  |
| -h    | --help                    | Show help, exit                                                                                                                                                                                                    |
| -v    | --version                 | Print current version, exit                                                                                                                                                                                        |
|       | --check                   | Check if all dependencies are installed, exit                                                                                                                                                                      |
| -c    | --connect                 | Show connected imgur account, exit                                                                                                                                                                                 |
| -s    | --select                  | Take screenshot in select mode                                                                                                                                                                                     |  
| -w    | --window                  | Take screenshot in window mode                                                                                                                                                                                     |  
| -f    | --full                    | Take screenshot in full mode                                                                                                                                                                                       |
| -o    | --open <true\|false>      | override *open* config                                                                                                                                                                                             |
| -e    | --edit <true\|false>      | override *edit* config                                                                                                                                                                                             |
| -i    | --edit-command <command>  | Override 'EDIT_COMMAND' config (include '%img'), sets --edit 'true'                                                                                                                                                |
| -l    | --login <true\|false>     | override *login* config                                                                                                                                                                                            |
| -a    | --album \<album_title\>   | Create new album and upload there                                                                                                                                                                                  |
| -A    | --album-id \<album_id\>   | override *album_id* config                                                                                                                                                                                         |
| -k    | --keep-file <true\|false> | override *keep_file* config                                                                                                                                                                                        |
| -d    | --auto-delete \<s\>       | automatically delete image after `s` seconds                                                                                                                                                                       |
| -u    | --update                  | check for updates, exit.<br>[Release versions](https://github.com/jomo/imgur-screenshot/releases) also apply found updates.<br>This is done automatically when `check_update` and `auto_update` are set to `true`. |
|       | *file* ...                | instead of uploading a screenshot, upload *file*                                                                                                                                                                   |

### Uploading a screenshot

All you need to do is simply run `imgur-screenshot.sh`.

### Uploading a screenshot to your account

```shell
imgur-screenshot.sh -c # shows you which account you're connected to
imgur-screenshot.sh -l true
```

---

_Making a selection:_<br>
![Selection](https://i.imgur.com/3G7BmdV.png)<br>


## Dependencies

(Most are probably pre-installed)<br>
**Tip:** Use [--check](#Installation) to see what's missing.

* curl
* jq
* **Linux only:**
* libnotify-bin
* scrot
* xclip <i>(needed for `copy_url`)</i>
* **OS X only:**
* [terminal-notifier](https://github.com/julienXX/terminal-notifier) *or* [growlnotify](http://growl.info/downloads#generaldownloads)


## OS support

With the above dependencies installed, imgur-screenshot should work on most UNIX systems.  
This will not work on Windows. (maybe with cygwin?)  
I have successfully tested this on Ubuntu and OS X.  
If this won't work on your OS, [create a new issue](https://github.com/jomo/imgur-screenshot/issues/new?title=add+support+for+_______&body=required+steps+to+make+it+work+on+______:).


## Note

The screenshot will be taken **after** the selection has been made. This might be annoying if you want to capture something quickly and _then_ want to select an area.
However, you can take a full shot and use the edit option to crop the image before upload.
