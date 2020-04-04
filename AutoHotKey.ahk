#SingleInstance Force
EnvGet, homePath, USERPROFILE
wtPath := homePath . "\wt-admin"
ahkScript := homePath . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotKey.ahk"
winTerminal := "ahk_exe WindowsTerminal.exe"
if !A_IsAdmin {
	Run *Runas %ahkScript%
}

~LButton & MButton::Send #{Tab}
~MButton & WheelDown::Send ^#{Right}
MButton & WheelUp::Send ^#{Left}
#!0::Send {Volume_Mute}
#!-::Send {Volume_Down}
#!=::Send {Volume_Up}

^`::
	if !WinExist(winTerminal) {
		Run, %wtPath%
	}
	else if WinActive(winTerminal) {
		WinMinimize, %winTerminal%
	}
	else if !WinActive(winTerminal) {
		WinActivate, %winTerminal%
	}
