#Requires AutoHotkey v2.0 
#SingleInstance Force

#Include Launch.ahk

; copied and updated for v2 from: https://www.autohotkey.com/docs/v1/lib/Run.htm#RunAs
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
    try {
        if A_IsCompiled
            Run("*RunAs `"" A_ScriptFullPath "`" /restart")
        else
            Run("*RunAs " A_AhkPath " /restart `"" A_ScriptFullPath "`"")
    }
    ExitApp()
}

; launch code
launch()