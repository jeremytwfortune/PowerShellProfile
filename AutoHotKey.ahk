#SingleInstance Force
EnvGet, homePath, USERPROFILE
ahkScript := homePath . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\AutoHotKey.ahk"

if !A_IsAdmin {
	Run *Runas %ahkScript%
}

VsCode() {
	vscode := "ahk_exe Code.exe"
	if WinActive(vscode) {
		WinMinimize, %vscode%
	}
	else if !WinActive(vscode) {
		WinActivate, %vscode%
	}
}

WinTerminal(homePath) {
	winTerminal := "ahk_exe WindowsTerminal.exe"
	wtPath := homePath . "\wt-admin"
	if !WinExist(winTerminal) {
		Run, %wtPath%
	}
	else if WinActive(winTerminal) {
		WinMinimize, %winTerminal%
	}
	else if !WinActive(winTerminal) {
		WinActivate, %winTerminal%
	}
	return

}

~LButton & MButton::Send #{Tab}
~MButton & WheelDown::Send ^#{Right}
MButton & WheelUp::Send ^#{Left}
#!0::Send {Volume_Mute}
#!-::Send {Volume_Down}
#!=::Send {Volume_Up}
!`::VsCode()
^`::WinTerminal(homePath)
