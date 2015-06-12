AHK Timer
=========
A countdown timer app written in AutoHotkey.

Features
--------
* Create multiple countdown timer.
* Use global hotkey.

Todos
-----
* Fix notify windows flashing. Use opacity=0 before moving?
* Move out language file?

Usage
-----
* Win + T to create a timer.

Setting
-------
```
[Setting]

; Is it the first time starting app?
FirstRun=0

; The hotkey
hotkey=#T

; Use popup window when time is up.
usingPopup=1

; Play sound when time is up.
beepSound=1

; Coordinate of popup window.
placeAt=6

; If time is up after app closed. Show popup directly when app start.
usingOutdate=0
```

License
-------
MIT
