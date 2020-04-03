~LButton & MButton::Send #{Tab}
~MButton & WheelDown::Send ^#{Right}
MButton & WheelUp::Send ^#{Left}
#!0::Send {Volume_Mute}
#!-::Send {Volume_Down}
#!=::Send {Volume_Up}
^`::
if !WinExist("Windows Terminal") {
	Run wt.exe split-pane -V
}
else if WinActive("Windows Terminal") {
	WinMinimize
}
else if !WinActive("Windows Terminal") {
	WinActivate
}
