The _**Imgur-Screenshot**_ uploader for Linux & OS X from [imgur.com/tools](https://imgur.com/tools)<br>

# Imgur-Screenshot

1. select area of your screen
1. The screenshot is uploaded to [imgur](https://imgur.com)

![screenshot gif](https://i.imgur.com/sGSw2CI.gif)


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

See also: [CONTRIBUTING.md](CONTRIBUTING.md)

## Installation

### Install on Mac via Homebrew

```shell
brew update && brew install imgur-screenshot
```

You will also need a newer version of `bash`, as the built-in macOS bash is too old.
```shell
brew install bash
```

### Install on ArchLinux via AUR

See [imgur-screenshot](https://aur.archlinux.org/packages/imgur-screenshot/) for the stable version, and [imgur-screenshot-git](https://aur.archlinux.org/packages/imgur-screenshot-git/) for the development version.

### Install on CentOS and Fedora via COPR

See [valdikss/imgur-screenshot](https://copr.fedorainfracloud.org/coprs/valdikss/imgur-screenshot/) on COPR.

### Install on NixOS via Nix

See [imgur-screenshot](http://hydra.nixos.org/search?query=imgur-screenshot) on Hydra.

### Install via git

```shell
git clone https://github.com/jomo/imgur-screenshot.git
```

### Download source

Alternatively, you can download `imgur-screenshot` from [releases](https://github.com/jomo/imgur-screenshot/releases).  
These builds have [auto-update.patch](auto-update.patch) applied, allowing to update via `--update`.

---

Make sure you have all dependencies installed (see below).

That's it.  
Bind the script to a hotkey or add it to your `$PATH` for quick access ;)

**Enjoy!**

## Usage

> **Note:** You can override the default configuration in `~/.config/imgur-screenshot/settings.conf`.  
> Check out [the wiki](https://github.com/jomo/imgur-screenshot/wiki/Config) for more!

```shell
imgur-screenshot [--debug] [-c | -v | -h | -u]
imgur-screenshot [--debug] [optiion]... [file]...
```

Run `imgur-screenshot -h` to see all command line options.

### Uploading a screenshot

All you need to do is simply run `imgur-screenshot`.

### Uploading a screenshot to your account

```shell
imgur-screenshot -c # shows you which account you're connected to
imgur-screenshot -l true
```

---

## Dependencies

* bash 4.2+
* curl
* jq
* **Linux only:**
* libnotify-bin
* scrot (or other screenshot tool)
* xclip <i>(needed for `copy_url`)</i>
* **macOS only:**
* [terminal-notifier](https://github.com/julienXX/terminal-notifier) *or* [growlnotify](http://growl.info/downloads#generaldownloads)


## OS support

With the above dependencies installed, imgur-screenshot should work on most UNIX systems.  
This will not work on Windows. (maybe with cygwin?)  
I have successfully tested this on Ubuntu and macOS.  
If this won't work on your OS, [create a new issue](https://github.com/jomo/imgur-screenshot/issues/new?title=add+support+for+_______&body=required+steps+to+make+it+work+on+______:).


## Note

The screenshot will be taken **after** the selection has been made. This might be annoying if you want to capture something quickly and _then_ want to select an area.
However, you can take a full shot and use the edit option to crop the image before upload.
