#SingleInstance Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;Global Vars
timerQue := Array()
LOG_FILE := "timer.txt"
ICON_FILE := "Icon.ico"
setting := {
(Join
	hotkey: "#t",
	firstRun: true,
	beep: true,
	popup: true,
	outdated: false,
	placeAt: 5
)}

loadSetting()

Hotkey, % setting.hotkey, MakeWindow

;Make tray menu
If (FileExist(ICON_FILE)) {
	Menu, tray, Icon, %ICON_FILE%
}
Menu, tray, tip, AHK Timer
Menu, tray, noStandard
Menu, tray, Add, 顯示視窗, ShowMainWindow
Menu, tray, Add, 結束, Exit
Menu, Tray, Default, 顯示視窗

;Timer
SetTimer, CheckTimer, 1000	;每秒檢查一次
SetTimer, CheckTimer, Off

;MainWindow
Gui, MainWindow: New, +LastFound, AHK Timer
Gui, Add, Tab, x-4 y-0 w480 h380 , 計時器管理|功能設定
Gui, font, s14, 微軟正黑體
Gui, Add, ListView, x6 y30 w462 h304 vtmList -Multi NoSortHdr, 計時器標題|剩餘時間
Gui, font,
Gui, Add, Button, x356 y340 w100 h30 gDeleteTimer, 刪除此計時器
Gui, Tab, 功能設定
Gui, Add, Text, x6 y37 w300 h20, 快速鍵:
Gui, Add, Edit, x47 y33 w60 h20 vghotKey disabled right,
Gui, Add, Button, x146 y29 w100 h30 gSetHotkey, 設定快速鍵
Gui, Add, CheckBox, x6 y67 w300 h30 voutdated gSaveSetting, 使用過期的計時器
Gui, Add, CheckBox, x6 y97 w300 h30 vpopup gSaveSetting, 使用跳出視窗
Gui, Add, CheckBox, x6 y127 w300 h30 vbeep gSaveSetting, 使用提示音
Gui, Add, Button, x322 y30 w40 h40 gChangeP vp1, ↖
Gui, Add, Button, x372 y30 w40 h40 gChangeP vp2, ↑
Gui, Add, Button, x422 y30 w40 h40 gChangeP vp3, ↗
Gui, Add, Button, x322 y80 w40 h40 gChangeP vp4, ←
Gui, Add, Button, x372 y80 w40 h40 gChangeP vp5, 。
Gui, Add, Button, x422 y80 w40 h40 gChangeP vp6, →
Gui, Add, Button, x322 y130 w40 h40 gChangeP vp7, ↙
Gui, Add, Button, x372 y130 w40 h40 gChangeP vp8, ↓
Gui, Add, Button, x422 y130 w40 h40 gChangeP vp9, ↘
Gui, Add, GroupBox, x6 y167 w460 h200, 關於
Gui, Add, Text, x16 y197 w440 h160 center, `n`n我的BLOG:`nhttp://eight04.blogspot.com`n`n我的MAIL:`neight04@gmail.com

;Initial ListView
LV_ModifyCol(1, "310")
LV_ModifyCol(2, "AutoHdr Right")

;Initial setting
GuiControl,, ghotkey, % setting.hotkey
GuiControl,, popup, % setting.popup
GuiControl,, beep, % setting.beep
GuiControl,, outdated, % setting.outdated
GuiControl, Disable, % "p" setting.placeAt

;Initial
if (setting.firstRun) {
	MsgBox, 4, 第一次執行,
	(LTrim
	第一次啟動, 此程式會執行在系統列！
	對圖示右鍵可以叫出設定選單

	需要再顯示這個提示嗎？
	)
	ifMsgBox, No, {
		setting.firstRun := 0
		saveSetting("firstRun")
	}
}

;Initial timer
readFromLog(timerQue)

return

; ==================== Label and Functions ==================

ChangeP:
	GuiControl, Enable, % "p" setting.placeAt
	setting.placeAt := SubStr(A_GuiControl, 2)
	GuiControl, Disable, % "p" setting.placeAt
	saveSetting("placeAt")
	return

DeleteTimer:
	fDeleteTimer(LV_GetNext(), timerQue)
	return

SetHotkey:
	hk := HotkeyGUI(0, setting.hotkey, 1, false, "設定快速鍵")	;HotkeyGUI Library
	if (!hk) {
		return
	}
	hotkey, % setting.hotkey, MakeWindow, off
	setting.hotkey := hk
	saveSetting("hotkey")
	hotkey, % setting.hotkey, MakeWindow, on
	Gui, MainWindow:Default
	GuiControl,, ghotkey, %hk%
	return

SaveSetting:
	setting[A_GuiControl] := getGuiValue(A_GuiControl)
	saveSetting(A_GuiControl)
	return

Exit:
	ExitApp
	return

ShowMainWindow:
	Gui, MainWindow:Default
	Gui, show, h376 w475, AHK Timer
	return

MakeWindow:
	; Create timer window
	Gui, TimerWindow:+LastFoundExist
	IfWinExist
	{
		WinActivate
		return
	}
	Gui, TimerWindow:New, -Caption +Border +LastFound +LabelTimerWindow, 開始一個新的計時器
	Gui, Font,, 細明體
	Gui, Add, Text,, 倒數計時器標題
	Gui, Add, Edit, vtimeTitle r1 w120
	Gui, Add, Text,, 輸入時間(時:分:秒)
	Gui, Add, Edit, vtimeData r1 w120, 00:00:00
	Gui, Add, Text,, 重覆執行(時:分:秒)
	Gui, Add, Edit, vtimeRepeat r1 w120, 00:00:00
	Gui, Add, Button, Default gCreateTimer, Start
	Gui, Show
	return

TimerWindowClose:
TimerWindowEscape:
	Gui, Destroy
	return

CreateTimer:
	Gui, Submit
	Gui, Destroy

	if (timeData="" || timeData="00:00:00") {
		return
	}

	; Parse title
	StringReplace, timeTitle, timeTitle, |, _, all

	; Parse end time
	endTime := timeAdd(A_Now, TimeData)

	; Create tip
	tipMessage := fTip(timeTitle, endTime)
	TrayTip, %timeTitle%, %tipMessage%

	addTimer(timerQue, timeTitle, endTime, timeRepeat)
	writeToLog(timerQue)
	return

checkTimer:	;計時器
	; Stop ticking if que is empty
	if (!timerQue.Length()) {
		setTimer, CheckTimer, Off
		Menu, tray, tip, AHK Timer
		return
	}

	; Loop through timers...
	loopTimerQue(timerQue)

	; Modify TreeView
	updateListView(timerQue)
	return

PopGuiEscape:
PopGuiClose:
	Gui, Destroy
	return

; ============================= Functions ============================

readFromLog(que) {
	global LOG_FILE

	args := []
	Loop, read, %LOG_FILE%, %LOG_FILE%~
	{
		arr := StrSplit(A_LoopReadLine, "`t")
		if (arr.Length() < 2) {
			continue
		}
		FileAppend, %A_LoopReadLine%`n
		args.push(arr[1], arr[2], arr[3])
	}
	FileDelete, %LOG_FILE%
	FileMove, %LOG_FILE%~, %LOG_FILE%

	addTimer(que, args*)
}

writeToLog(que){
	global LOG_FILE

	FileDelete, %LOG_FILE%
	For index, value in que {
		line := value.title "`t" value.endTime "`t" value.repeat "`n"
		FileAppend, %line%, %LOG_FILE%
	}
}

loadSetting() {
	global setting
	for key, value in setting {
		IniRead, value, Setting.ini, Setting, %key%, %value%
		setting[key] := value
	}
}

saveSetting(key:="") {
	global setting
	if (key) {
		value := setting[key]
		IniWrite, %value%, Setting.ini, Setting, %key%
	} else {
		for key, value in setting {
			IniWrite, %value%, Setting.ini, Setting, %key%
		}
	}
}

fDeleteTimer(index, que) {
	Gui, MainWindow:Default
	que.RemoveAt(index)
	LV_Delete(index)
}

timeAdd(baseTime, diff) {
	arr := StrSplit(diff, ":")
	Loop, % 3 - arr.Length() {
		arr.InsertAt(0, 0)
	}

	baseTime += arr[1], H
	baseTime += arr[2], M
	baseTime += arr[3], S

	return baseTime
}

time2Arr(endTime) {
	T := A_Now
	h := endTime
	h -= T, H
	m := endTime
	m -= T, M
	m := mod(m, 60)
	s := endTime
	s -= T, S
	s := mod(s, 60)
	return [h, m, s]
}

; Format tray tip
fTip(title, endTime) {
	arr := time2Arr(endTime)
	return title " 還剩 " arr[1] " 時 " arr[2] " 分 " arr[3] " 秒"
}

; Format time
fTime(endTime) {
	arr := time2Arr(endTime)
	for key, value in arr {
		if (value < 10) {
			arr[key] := "0" value
		}
	}
	return arr[1] ":" arr[2] ":" arr[3]
}

Popup(title) {
	global setting
	if (setting.popup) {
		Gui, New, +AlwaysOnTop +LabelPopGui +LastFound, %title%
		Gui, Font, s12, 細明體
		Gui, margin, 15, 12
		Gui, Add, Text,, %title%時間到啦！
		Gui, Add, Button, gpopGuiClose default, 我知道了
		WinSet, Transparent, 0
		Gui, Show, noActivate, %title%

		SysGet, ScreenWidth, 16
		SysGet, ScreenHeight, 17
		SysGet, gCaption, 4
		screenHeight := ScreenHeight + gCaption - 20
		screenWidth := screenWidth - 20
		WinGetPos,,, w, h

		if (setting.placeAt <= 3) {
			y := 0
		} else if (setting.placeAt <= 6) {
			y := (screenHeight - h) / 2
		} else {
			y := (screenHeight - h)
		}

		col := Mod(setting.placeAt, 3)
		if (col = 1) {
			x := 0
		} else if (col = 2) {
			x := (screenWidth - w) / 2
		} else {
			x := screenWidth - w
		}

		x += 10
		y += 10

		WinMove x, y
		WinSet, Transparent, OFF

	} else {
		TrayTip, %title%, %title% 時間到了！
	}

	if (setting.beep) {
		SoundPlay, *48
	}
}

getGuiValue(key) {
	GuiControlGet, value,, %key%
	return value
}

loopTimerQue(que) {
	global setting

	saveFlag := false
	tipQ := ""
	readd := []
	i := 1

	; Update tray tip, popup
	loop {
		if (i > que.Length()) {
			break
		}
		item := que[i]
		if (A_Now >= item.endTime) {
			diff := A_Now
			diff -= item.endTime, S
			line := setting.outdated ", " diff
			if (setting.outdated || diff < 5) {
				Popup(item.title)
			}
			newEndTime := timeAdd(item.endTime, item.repeat)
			fDeleteTimer(i, que)
			if (item.endTime < newEndTime) {
				readd.Push([item.title, newEndTime, item.repeat])
			}
			saveFlag := true

		} else {
			if (A_Index <= 3) {
				if (A_Index > 1) {
					tipQ .= "`n"
				}
				tipQ .= fTip(item.title, item.endTime)
			}
			i++
		}
	}

	for key, item in readd {
		addTimer(que, item*)
	}

	if (saveFlag) {
		writeToLog(que)
	}

	Menu, tray, tip, %tipQ%
}

updateListView(que) {
	Gui, MainWindow:Default
	Gui, +LastFoundExist
	ifWinNotExist
	{
		return
	}
	for index, value in que {
		LV_Modify(index, "Col2", fTime(value.endTime))
	}
}

getInsertPoint(que, item) {
	for key, value in que {
		if (value.endTime > item.endTime) {
			return key
		}
	}
	return que.Length() + 1
}

addTimer(que, args*) {
	Gui, MainWindow:Default
	index := 1
	len := args.Length()
	while (index < len) {
		item := {
		(Join
			title: args[index],
			endTime: args[index + 1],
			repeat: args[index + 2]
		)}
		key := getInsertPoint(que, item)
		que.InsertAt(key, item)
		LV_Insert(key,, item.title, fTime(item.endTime))
		index += 3
	}
	SetTimer, CheckTimer, On
}
