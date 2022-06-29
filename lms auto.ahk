﻿;
; AHK file - UTF8 + BOM
; INI file - UTF8 (w/o BOM)
;

#NoEnv
#NoTrayIcon
#SingleInstance Ignore
SetWorkingDir, %A_ScriptDir%
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; Global Vars
Global Title := "lms auto"
Global RefDir := A_ScriptDir
Global IniFile := RefDir . "\" . Title . ".ini"

Global WinId
Global hGui
Global hwndCtrl_Log
Global flagStop := false

Global lastx, lasty

Global scanfile := ["06.png"]
Global searchfile := ["01.png", "02.png", "03.png", "04.png", "05.png"]
Global loopRound := 2400
; Gui Creation

Gui, New, hwndhGui MinSize ;, Resize

Gui, Font,, Malgun Gothic

Gui, Add, GroupBox, Section x10 y6 w320 h64, 공통

Gui, Add, Button, xs+12 ys+18 w60 h36 gStart, 시 작
Gui, Add, Button, x+12 w60 h36 gSaveINI, 설정 저장
Gui, Add, Button, x+72 w60 h36 gStop, 중 지

Gui, Add, GroupBox, Section xs w320 h80, 스캔 영역 설정
Gui, Add, Text, xs+12 ys+20, 좌상단 좌표
Gui, Add, Text, x+8, x
Gui, Add, Edit, x+2 yp-3 w36 Limit4 vx1
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit4 vy1
Gui, Add, Text, xs+12 y+6, 우하단 좌표
Gui, Add, Text, x+8, x
Gui, Add, Edit, x+2 yp-3 w36 Limit4 vx2
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit4 vy2

Gui, Add, Progress, Section xs w320 h4 Range0-%loopRound% vLoopProgress, 0

Gui, Add, Text, Section xs, 로그
Gui, Add, Edit,  w320 r20 HwndhwndCtrl_Log ReadOnly vCtrl_Log

Gui, Add, GroupBox, Section x+10 y6 w320 h80, 그림1
Gui, Add, Picture, xs+12 ys+20 gReloadScript, % RefDir "\" searchfile[1]
Gui, Add, Text, x+12 yp, 클릭 좌표 보정
Gui, Add, Text, xp y+6, x
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vxf1, 10
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vyf1, 10

Gui, Add, GroupBox, Section xs w320 h80, 그림2
Gui, Add, Picture, xs+12 ys+20 gReloadScript, % RefDir "\" searchfile[2]
Gui, Add, Text, x+12 yp, 클릭 좌표 보정
Gui, Add, Text, xp y+6, x
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vxf2, 10
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vyf2, 10

Gui, Add, GroupBox, Section xs w320 h80, 그림3
Gui, Add, Picture, xs+12 ys+20 gReloadScript, % RefDir "\" searchfile[3]
Gui, Add, Text, x+12 yp, 클릭 좌표 보정
Gui, Add, Text, xp y+6, x
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vxf3, 10
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vyf3, 10

Gui, Add, GroupBox, Section xs w320 h80, 그림4
Gui, Add, Picture, xs+12 ys+20 gReloadScript, % RefDir "\" searchfile[4]
Gui, Add, Text, x+12 yp, 클릭 좌표 보정
Gui, Add, Text, xp y+6, x
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vxf4, 10
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vyf4, 10

Gui, Add, GroupBox, Section xs w320 h80, 그림5
Gui, Add, Picture, xs+12 ys+20 gReloadScript, % RefDir "\" searchfile[5]
Gui, Add, Text, x+12 yp, 클릭 좌표 보정
Gui, Add, Text, xp y+6, x
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vxf5, 10
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit3 vyf5, 10

Gui, Add, GroupBox, Section xs w320 h80, 그림6 클릭위치 고정

Gui, Add, Picture, xs+12 ys+20 gReloadScript, % RefDir "\" scanfile[1]
Gui, Add, Text, x+12 yp, 클릭 좌표
Gui, Add, Text, xp y+6, x
Gui, Add, Edit, x+2 yp-3 w36 Limit4 vx3
Gui, Add, Text, x+4 yp+3, y
Gui, Add, Edit, x+2 yp-3 w36 Limit4 vy3


GoSub ReadINI

Gui, Show,, %Title%
Winget, WinId, ID, %Title%

GetClientSize(hGui, temp)
horzMargin := temp*96//A_ScreenDPI - 320

Log("┌ 사이버연수 자동`r`n")
Log("│ q: 스캔 영역 왼쪽 위 지정`r`n")
Log("│ w: 스캔 영역 오른쪽 아래 지정`r`n")
Log("└ e: 클릭 위치 지정`r`n")
Log("`r`n")

IniRead, wX, % IniFile, Common, GUI_x, 600
IniRead, wY, % IniFile, Common, GUI_y, 50
WinMove, A,, wX, wY

Hotkey,IfWinActive, ahk_id %WinId%
Hotkey, q, Set
Hotkey, w, Set
Hotkey, e, Set

Return

Start:
	Log(Format("{1} {2} {3} {4}`r`n",xf1,yf1,xf2,yf2))
	FormatTime, timeStart, Hmmss, HH:mm:ss
	Log("`r`n   ==== START " . timeStart . " ====   `r`n")
	flagStop := false

	WaitNext()

	FormatTime, timeEnd, Hmmss, HH:mm:ss
	Log("`r`n   ==== END " . timeEnd . " ====   `r`n")
Return

Stop:
	Log("`r`n     == 중단 예약 ==   `r`n")
	flagStop := true
Return

GetClientSize(hWnd, ByRef w := "", ByRef h := "") {
	VarSetCapacity(rect, 16)
	DllCall("GetClientRect", "ptr", hWnd, "ptr", &rect)
	w := NumGet(rect, 8, "int")
	h := NumGet(rect, 12, "int")
}

Log(str) {
	AppendText(hwndCtrl_Log, &str)
}

LogClear() {
	GuiControl,, Ctrl_Log,
}

WaitNext() {
	Log("[대기 중]`r`n")
	n := 1
	dX := ""
	dY := ""
	mlx := 0	; mouse last position
	mly := 0

	Loop, %loopRound% {
		if (flagStop) {
            GuiControl,, LoopProgress, %A_Index%
			Break
        }

		; 스크린세이버 방지(20 * 3초 = 1분)
		MouseGetPos, cx, cy
		if(Mod(A_Index, 20) == 0) {
			if(mlx == cx && mly == cy) {
				Log(" * 스크린세이버 방지`r`n")
				Random, rand, 0, 1
				if (rand) {
					cx += 1
				cy += 1
				} else {
					cx -= 1
					cy -= 1
				}
				MouseMove, cx, cy
			}
		}
		mlx := cx
		mly := cy

		; 그림6
		GuiControlGet, x_1,, x1
		GuiControlGet, y_1,, y1
		GuiControlGet, x_2,, x2
		GuiControlGet, y_2,, y2
		imgFile := RefDir . "\" . scanfile[1]

		ImageSearch, dX, dY, x_1,y_1, x_2,y_2, *10 *TransBlack %imgFile%
		;Log(".")
		if(dX != "") {
			Clik(1)
			Break
		}

		SearchFile(1)
		|| SearchFile(2)
		|| SearchFile(3)
		|| SearchFile(4)
		|| SearchFile(5)

		Sleep, 2800
        GuiControl,, LoopProgress, %A_Index%
	}
}

SearchFile(n, transColor := "Black") {
	GuiControlGet, x_1,, x1
	GuiControlGet, y_1,, y1
	GuiControlGet, x_2,, x2
	GuiControlGet, y_2,, y2

	GuiControlGet, xf,, xf%n%
	GuiControlGet, yf,, yf%n%

	imgFile := RefDir . "\" . searchfile[n]
	ImageSearch, dX, dY, x_1,y_1, x_2,y_2, *10 *Trans%transColor% %imgFile%
	if(dX) {
		Log("Find 2-" . n . " " . dX . " / " . dY)
		Clik2(2, dX+xf, dY+yf)
		return true
	}
	return false
}

Clik2(n, ddx, ddy) {
	FormatTime, timeV, Hmmss, HH:mm:ss
	Log(" * [그림" . n . "] 발견 - " . timeV . "`r`n")
	keyState := GetKeyState("LButton") + GetKeyState("RButton") + GetKeyState("Alt") + GetKeyState("Ctrl") + GetKeyState("Shift") + GetKeyState("RWin") + GetKeyState("LWin")
	if(keyState) {
		Log(" * 마우스 또는 키보드 사용 중 - 1초 후 재시도`r`n")
		Sleep, 1000
		return
	}
	WinGet, cWinId, ID, A
	WinGetTitle, cWinTitle, A
	BlockInput, On
	MouseGetPos, cx, cy
	Log("  - 현재 창 : " . cWinId . " / 마우스 : " . cx . "," . cy . "`r`n")
	n *= 3
	Log(" * 클릭(" . ddx . "," . ddy . ")`r`n")
	Click, %ddx%, %ddy%
	Sleep, 20
	MouseMove, cx, cy
	BlockInput, Off
	WinActivate, ahk_id %cWinId%
	Log(" * 기존 창 / 마우스 복귀`r`n")
	Sleep, 5000
}


Clik(n) {
	FormatTime, timeV, Hmmss, HH:mm:ss
	Log(" * [그림" . n . "] 발견 - " . timeV . "`r`n")
	keyState := GetKeyState("LButton") + GetKeyState("RButton") + GetKeyState("Alt") + GetKeyState("Ctrl") + GetKeyState("Shift") + GetKeyState("RWin") + GetKeyState("LWin")
	if(keyState) {
		Log(" * 마우스 또는 키보드 사용 중 - 1초 후 재시도`r`n")
		Sleep, 1000
		return
	}
	WinGet, cWinId, ID, A
	WinGetTitle, cWinTitle, A
	BlockInput, On
	MouseGetPos, cx, cy
	Log("  - 현재 창 : " . cWinId . " / 마우스 : " . cx . "," . cy . "`r`n")
	n *= 3
	GuiControlGet, dx,, x%n%
	GuiControlGet, dy,, y%n%
	Log(" * 클릭(" . dx . "," . dy . ")`r`n")
	Click, %dx%, %dy%
	Sleep, 20
	MouseMove, cx, cy
	BlockInput, Off
	WinActivate, ahk_id %cWinId%
	Log(" * 기존 창 / 마우스 복귀`r`n")
	Sleep, 5000
}

ReportError() {
	Log("실패!`r`n`r`n == 진행 불가! 스크립트 중지 ==`r`n")
	Log("== 홈 화면으로 ==`r`n")
	Pause, On
}

AppendText(hEdit, ptrText) {
	SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
	SendMessage, 0x00B1, ErrorLevel, ErrorLevel,, ahk_id %hEdit% ;EM_SETSEL
	SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
}

GuiSize:
	Gui %hGui%:Default
	if !horzMargin
		return
	ctrlW := A_GuiWidth - horzMargin
	list = Title,Status,VisText,AllText,Freeze
	Loop, Parse, list, `,
		GuiControl, Move, Ctrl_%A_LoopField%, w%ctrlW%
Return

ReloadScript:
	WinGetPos, wX, wY
	IniWrite, % wX, % IniFile, Common, GUI_x
	IniWrite, % wY, % IniFile, Common, GUI_y
	Reload
Return

GuiClose:
GuiEscape:
	WinGetPos, wX, wY
	IniWrite, % wX, % IniFile, Common, GUI_x
	IniWrite, % wY, % IniFile, Common, GUI_y
ExitApp

ReadINI:
	Loop, 6 {
		IniRead, tempVar, % IniFile, Common, x%A_Index%, %A_Space%
		GuiControl,, x%A_Index%, % tempVar
		IniRead, tempVar, % IniFile, Common, y%A_Index%, %A_Space%
		GuiControl,, y%A_Index%, % tempVar
	}
	Loop, 5 {
		IniRead, tempVar, % IniFile, Common, xf%A_Index%, %A_Space%
		GuiControl,, xf%A_Index%, % tempVar
		IniRead, tempVar, % IniFile, Common, yf%A_Index%, %A_Space%
		GuiControl,, yf%A_Index%, % tempVar
	}
Return

SaveINI:
	Loop, 6 {
		GuiControlGet, tempVar,, x%A_Index%
		IniWrite, % tempVar, % IniFile, Common, x%A_Index%
		GuiControlGet, tempVar,, y%A_Index%
		IniWrite, % tempVar, % IniFile, Common, y%A_Index%
	}
	Loop, 5 {
		GuiControlGet, tempVar,, xf%A_Index%
		IniWrite, % tempVar, % IniFile, Common, xf%A_Index%
		GuiControlGet, tempVar,, yf%A_Index%
		IniWrite, % tempVar, % IniFile, Common, yf%A_Index%
	}
	GoSub ReadINI
Return

Set:
	n := A_ThisHotkey
	if (n == "q")
		n := 1
	if (n == "w")
		n := 2
	if (n == "e")
		n := 3
	Gui %hGui%:Default
	MouseGetPos, mX, mY
	GuiControl,, x%n%, %mX%
	GuiControl,, y%n%, %mY%
Return
