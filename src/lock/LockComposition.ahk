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

    ; --- COMPARISON ---

    Composes(other) {
        ; type check
        if !(other is LockComposition) {
            throw TypeError("other must be a LockComposition")
        }

        ; loop other contents and check if all are contained in this
        for ponet in other {
            if !this.List.Has(ponet) {
                return false
            }
        }
        return true
    }
}