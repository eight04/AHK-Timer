#SingleInstance Force
#MaxThreadsPerHotkey 1
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

setting := {
	hotkey: "#t",
	firstRun: true,
	beepSound: true,
	popup: true,
	outdated: false,
	placeAt: 5
}

loadSetting()

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

Hotkey, %setting.hotkey%, MakeWindow

;Make tray menu
ifExist, Icon.ico
	Menu, tray, Icon, Icon.ico
Menu, tray, tip, AHK Timer
Menu, tray, noStandard
Menu, tray, Add, 顯示視窗, ShowMainWindow
Menu, tray, Add, 結束, Exit
Menu, Tray, Default, 顯示視窗

;Vars 
class TimerItem
{
	__New(title,endTime){
		this.title:=title
		this.endTime:=endTime
	}
}
timerQue:=Array()
LV_Selected:=0

;Timer
SetTimer, CheckTimer, 1000	;每秒檢查一次
SetTimer, CheckTimer, Off

;MainWindow
Gui, +LabelMainWindow +LastFound
Gui, Add, Tab, x-4 y-0 w480 h380 , 計時器管理|功能設定
Gui, font, s14, 微軟正黑體
Gui, Add, ListView, x6 y30 w462 h304 vtmList -Multi NoSortHdr, 計時器標題|剩餘時間
Gui, font,
Gui, Add, Button, x356 y340 w100 h30 gDeleteTimer, 刪除此計時器
Gui, Tab, 功能設定
Gui, Add, Text, x6 y37 w300 h20, 快速鍵:
Gui, Add, Edit, x47 y33 w60 h20 vghotKey disabled right, 
Gui, Add, Button, x146 y29 w100 h30 gSetHotkey, 設定快速鍵
Gui, Add, CheckBox, x6 y67 w300 h30 vuseOutdate gSaveSetting, 使用過期的計時器
Gui, Add, CheckBox, x6 y97 w300 h30 vusePopup gSaveSetting, 使用跳出視窗
Gui, Add, CheckBox, x6 y127 w300 h30 vuseBeep gSaveSetting, 使用提示音
Gui, Add, Button, x322 y30 w40 h40 gP1 vp1, ↖
Gui, Add, Button, x372 y30 w40 h40 gP2 vp2, ↑
Gui, Add, Button, x422 y30 w40 h40 gP3 vp3, ↗
Gui, Add, Button, x322 y80 w40 h40 gP4 vp4, ←
Gui, Add, Button, x372 y80 w40 h40 gP5 vp5, 。
Gui, Add, Button, x422 y80 w40 h40 gP6 vp6, →
Gui, Add, Button, x322 y130 w40 h40 gP7 vp7, ↙
Gui, Add, Button, x372 y130 w40 h40 gP8 vp8, ↓
Gui, Add, Button, x422 y130 w40 h40 gP9 vp9, ↘
Gui, Add, GroupBox, x6 y167 w460 h200, 關於
Gui, Add, Text, x16 y197 w440 h160 center, `n`n我的BLOG:`nhttp://eight04.blogspot.com`n`n我的MAIL:`neight04@gmail.com

;Get MainHWND
MainHWND:=WinExist()

;Initial
if (setting.firstRun) {
	MsgBox, 4, 第一次執行,
	(LTrim
	第一次啟動, 此程式會執行在系統列！
	對圖示右鍵可以叫出設定選單

	需要再顯示這個提示嗎？
	)
	ifMsgBox No {
		setting.firstRun := 0
		saveSetting("firstRun")
	}
}

;Initial setting
GuiControl,, ghotkey, %setting.hotkey%
GuiControl,, usePopup, %setting.popup%
GuiControl,, useBeep, %setting.beepSound%
GuiControl,, useOutdate, %setting.outdated%
GuiControl, Disable, p%setting.placeAt%

;Initial timer
Loop, read, tm.log, tm.log~
{
	StringSplit, q, A_LoopReadLine, %A_Tab%
	if(q0 < 2)
		continue
	if(q1 < A_Now && !setting.outdated)
		continue
	FileAppend, %A_LoopReadLine%`n
	o := new TimerItem(q2,q1)
	timerQue.insert(o)
}
FileDelete, tm.log
FileMove, tm.log~, tm.log

;Initial ListView
For i,v in timerQue
{
	LV_Add(0, v.title, fTime(v.endTime))
}
LV_ModifyCol(1,"310")
LV_ModifyCol(2,"AutoHdr Right")

;Timer Start
SetTimer, CheckTimer, On

return

P1:
sp:=1
Goto, ChangeP
P2:
sp:=2
Goto, ChangeP
P3:
sp:=3
Goto, ChangeP
P4:
sp:=4
Goto, ChangeP
P5:
sp:=5
Goto, ChangeP
P6:
sp:=6
Goto, ChangeP
P7:
sp:=7
Goto, ChangeP
P8:
sp:=8
Goto, ChangeP
P9:
sp:=9
Goto, ChangeP

ChangeP:
GuiControl, Enable, p%setting.placeAt%
GuiControl, Disable, p%sp%
setting.placeAt := sp
saveSetting("placeAt")
return

DeleteTimer:
fDeleteTimer(LV_GetNext(),timerQue)
return

fDeleteTimer(i,timerQue){
	timerQue.remove(i)
	LV_Delete(i)
	writeToLog(timerQue)
}

SetHotkey:
hk := HotkeyGUI(0, setting.hotkey, 1, false, "設定快速鍵")	;HotkeyGUI Library
if(hk="")
	return
hotkey, %setting.hotkey%, MakeWindow, off
setting.hotkey := hk
saveSetting("hotkey")
hotkey, %setting.hotkey%, MakeWindow, on
Gui 1: default
GuiControl,, ghotkey, %hk%
return

SaveSetting:
Gui, Submit, Nohide
setting.popup := usePopup
setting.beepSound := useBeep
setting.outdated := useOutdate
saveSetting()
return

Exit:
ExitApp
return

ShowMainWindow:
Gui, show, h376 w475, AHK Timer
return

MakeWindow:
Gui 2:Default
Gui, +LastFoundExist
IfWinExist
{
	WinActivate
	return
}
Gui, -Caption +Border +LastFound +LabelCTimerWindow
Gui, Font,, 細明體
Gui, Add, Text,, 倒數計時器標題
Gui, Add, Edit, vtimeTitle r1 w120
Gui, Add, Text,, 輸入時間(時:分:秒)
Gui, Add, Edit, vtimeData r1 w120, 00:00:00
Gui, Add, Button, Default gCreateTimer, Start
Gui, Show,, 開始一個新的計時器
return

CTimerWindowClose:
CTimerWindowEscape:
Gui, Destroy
return

CreateTimer:
Gui, Submit
Gui, Destroy
StringReplace, timeTitle, timeTitle, |, _, all
if (timeData="" || timeData="00:00:00")
	return
Hour:=0	;分析時間
Minute:=0
Second:=0
StringSplit, t, TimeData, :
i:=0
ar:=[0,0,0]
loop, %t0%
{
	ar[i]:=t%t0%
	t0--
	i++
}
Second:=ar[0]
Minute:=ar[1]
Hour:=ar[2]
EndTime=%A_Now%
EndTime+=Hour,H
EndTime+=Minute,M
EndTime+=Second,S	
t:=fTip(timeTitle,endTime)
TrayTip, %timeTitle%, %t%
o:=new TimerItem(timeTitle, endTime)
timerQue.Insert(o)
Gui 1: Default
LV_Add(0,timeTitle,fTime(endTime))
SetTimer, CheckTimer, On
writeToLog(timerQue)
return

checkTimer:	;計時器
if (! timerQue.MaxIndex())
{
	setTimer, CheckTimer, Off
	Menu, tray, tip, AHK Timer
	return
}
TipQ=
For i,v in timerQue
{
	_endTime:=v.endtime	;這邊加底線是避免打斷其它thread，變數稱重覆的bug
	_timeTitle:=v.title	;根本的解決法是改用區域變數
	if (A_now > _endTime)
	{
		fDeleteTimer(i,timerQue)
		Popup(_timeTitle)
	}
	else
	{
		if TipQ <>
			TipQ:=TipQ . "`n"
		TipQ:=TipQ . fTip(_timetitle,_endTime)
	}
}
Menu, tray, tip, %TipQ%

;Modify TreeView
ifWinExist, AHK_ID %MainHWND%
{
	For i,v in timerQue
	{
		LV_Modify(i,"Col2",fTime(v.endTime))
	}
}
return

fTip(title,endTime){
	T:=A_Now
	h:=endTime
	h-=T,H
	m:=endTime
	m-=T,M
	m:=mod(m,60)
	s:=endTime
	s-=T,S
	s:=mod(s,60)
	return title . " 還剩 " . h . " 時 " . m . " 分 " . s . "秒"
}

fTime(endTime){
	T:=A_Now
	h:=endTime
	h-=T,H
	if ( h < 10 )
		h = 0%h%
	m:=endTime
	m-=T,M
	m:=mod(m,60)
	if ( m < 10 )
		m = 0%m%
	s:=endTime
	s-=T,S
	s:=mod(s,60)
	if ( s < 10 )
		s = 0%s%
	return h . ":" . m . ":" . s
}

selectL:
LV_Selected:=A_EventInfo
;msgBox %LV_Selected%
return

Popup(title){
	global setting
	if (setting.beepSound) {
		SoundPlay, *48
	}
	if (setting.popup) {
		loop, 99 {
			if A_Index <= 2
				continue
			gui %A_Index%:+LastFoundExist
			IfWinNotExist
			{
				Gui %A_Index%: default
				Break
			}
		}
		SysGet, ScreenWidth, 16
		SysGet, ScreenHeight, 17
		SysGet, gCaption, 4
		screenHeight := ScreenHeight + gCaption - 20
		screenWidth := screenWidth - 20
		Gui +AlwaysOnTop +ToolWindow +LabelPopGui +LastFound
		Gui, Font, s12, 細明體
		Gui, margin, 15, 12
		Gui, Add, Text,, %title%時間到啦！
		Gui, Add, Button, gpopGuiClose, 我知道了
		Gui, Show, noActivate, %title%
		WinGetPos,,, w, h
		if (setting.placeAt = 1) {
			x:=0
			y:=0
		}
		if (setting.placeAt = 2) {
			x:=(screenWidth-w)/2
			y:=0
		}
		if (setting.placeAt = 3) {
			x:=screenWidth-w
			y:=0
		}
		if (setting.placeAt = 4) {
			x:=0
			y:=(screenHeight-h)/2
		}
		if (setting.placeAt = 5) {
			x:=(screenWidth-w)/2
			y:=(screenHeight-h)/2
		}
		if (setting.placeAt = 6) {
			x:=(screenWidth-w)
			y:=(screenHeight-h)/2
		}
		if (setting.placeAt = 7) {
			x:=0
			y:=(screenHeight-h)
		}
		if (setting.placeAt = 8) {
			x:=(screenWidth-w)/2
			y:=(screenHeight-h)
		}
		if (setting.placeAt = 9) {
			x:=(screenWidth-w)
			y:=(screenHeight-h)
		}
		x:=x+10
		y:=y+10
		WinMove x,y
	}
	else
	{
		TrayTip, %title%, %title% 時間到了！
	}
	return
}

PopGuiEscape:
PopGuiClose:
Gui, Destroy
return

writeToLog(q){
	For i,v in q
	{
		t:=v.title
		s:=v.endTime
		FileAppend, %s%`t%t%`n, tm.log~
	}
	FileDelete, tm.log
	FileMove, tm.log~, tm.log
}