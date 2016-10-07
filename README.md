AHK Timer
=========
A countdown timer app written in AutoHotkey.

Features
--------
* Create multiple countdown timer.
* Use global hotkey to create timer.
* Call the timer repeatly with specified period.

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

; Loop the sound until the popup is closed
beepLoop=0

; It can be a file name or following values:
; *-1 = Simple Beep
; *16 = Error
; *32 = Question
; *48 = Exclamation
; *64 = Info
sound=*48
```

License
-------
MIT
