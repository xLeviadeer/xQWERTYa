#Requires AutoHotkey v2.0

#Include ../../src/profile/Profile.ahk
#Include ../../src/modifier/Modifier.ahk

class ModifierActions {
    ; --- CURL ---

    static CapsLockOff() {
        SetCapsLockState("AlwaysOff")
    }

    ; --- WINDOWS ---

    static Windows() {
        SendInput("{RWin}")
    }

}