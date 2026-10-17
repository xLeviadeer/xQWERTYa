#Requires AutoHotkey v2.0

#Include ../key/ActionExecutor.ahk

; contains methods for using the clipboard
class Clipboard {
    
    ; run a function on clipboard contents and reset clipboard to original contents
    ; method is expected to be a function which takes 1 argument which is the currently highlighted text
    static UseHighlighted(method) {
        ; validate method is a function
        if (!(
            (method is Func)
            || (method is BoundFunc)
        )) {
            throw TypeError("method value must be a function")
        }

        ; save clipboard state
        clip_save := ClipboardAll()
        A_Clipboard := ""

        ; get highlighted text
        ActionExecutor.SendInput("^c")
        ClipWait(, 1)
        clip_content := A_Clipboard

        ; run method
        method.Call(clip_content)

        ; restore clipboard
        A_Clipboard := clip_save
    }
}