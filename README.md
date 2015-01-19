## Dependencies
* [xmonad](http://xmonad.org/)
* [xmobar](http://projects.haskell.org/xmobar/)
* [urxvt](https://wiki.archlinux.org/index.php/rxvt-unicode)

## xmonad
Configured for a two-monitor setup with xmobar for the toolbar.

#### Numpad
I use my numpad keys as xmonad hot keys.
* `0` 0th workspace (main web browsing)
* `.` 1st workspace (development)
* `1` 2nd workspace (mail and calendar)
* `2` 3rd workspace (music)
* `3-6` 4th-7th workspaces (terminals and misc.)
* `7-9` _unused_
* `/` switch to left monitor
* `*` switch to right monitor
* `-` lock screen
* `+` spawn terminal

## xmobar
* Graphical CPU monitor
* Graphical Memory monitor
* Text volume indicator (script in `xmonad/`)
* Text bitcoin ticker (script in `xmonad/`)
* Date/time indicator
