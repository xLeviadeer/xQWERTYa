#Requires AutoHotkey v2.0

#Include ../tools/Composition.ahk
#Include Lock.ahk

; holds a composition of locks
class LockComposition extends Composition {

    ; --- VARIABLES ---

    Priority() {
        return Lock.Priority
    }
    Blank() {
        return false
    }

    ; --- FUNCTIONS ---

    ValidateKeystr(lck) {
        Lock.CheckValidLock(lck)
    }
}