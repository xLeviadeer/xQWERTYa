#Requires AutoHotkey v2.0

#Include ../../src/key/Key.ahk
#Include ../../src/profile/Profile.ahk

class LockActions {
    static _RealDisincludes => [
        "PrintScreen",
        "RAlt"
    ]
    static OnRealChange(bool) {
        if bool {
            ; if setting to on
            ; set all disincludes to true (on)
            ; set all else to false (off) explicitly
            Key.SetKeys(true, LockActions._RealDisincludes, false, true)
        } else {
            ; if setting to off
            ; set back to current profile settings
            Profile.SetExceptions(Profile.Curr)
        }
    }
}