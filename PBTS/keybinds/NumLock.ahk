#Include ../Locks.ahk
#Include ../Badge.ahk
#Include ../Key/Modifier.ahk
#Include ../Badge.ahk

class NumLock {
    static target => "NumLock"
    
    static do_panic := true

    static panic() {
        if (NumLock.do_panic == false) { 
            return 
        }
        for (modifier_name, modifier_value in ModifierTracker.List) {
            modifier_value.panic()
        }
        SetCapsLockState("AlwaysOff")
        Badge.ShowBadge(
            "Panicked!", 
            "Middle",
            "b9b480",
            "ff9100"
        )
    } 
}