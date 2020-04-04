EnvGet, homePath, USERPROFILE
wtPath := homePath . "\wt-admin"

~LButton & MButton::Send #{Tab}
~MButton & WheelDown::Send ^#{Right}
MButton & WheelUp::Send ^#{Left}
#!0::Send {Volume_Mute}
#!-::Send {Volume_Down}
#!=::Send {Volume_Up}

^`::
if !WinExist("Windows Terminal") {
	Run, %wtPath%
}
else if WinActive("Windows Terminal") {
	WinMinimize
}
else if !WinActive("Windows Terminal") {
	WinActivate
}
