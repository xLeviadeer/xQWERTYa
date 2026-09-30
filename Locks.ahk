#Include ./Key/Key.ahk

; holds data about locks like caps lock and arrow lock
class Locks {

    ; - Settings -

    static BADGE_SIDE => "Right"
    static ON_COLOR => "A5D2A5"
    static OFF_COLOR => "D2A5A5"

    ; - locks map - 

    ; a map where
    ;   key — a KeyProfile modifier name for a lock
    ;   value
    ;       locked — the locked status of this lock
    ;       modifier — the modifier name to access this lock (prevalent in locks like shift + arrow)
    static AccessMap => Map(
        KeyProfile.ARROWLOCK_NAME, {locked: Locks.isArrowLockedRef, modifier: KeyProfile.DEFAULT_NAME},
        KeyProfile.ARROWLOCK_SHIFT_NAME, {locked: Locks.isArrowLockedRef, modifier: ModifierTracker.SHIFT_NAME},
        KeyProfile.ARROWLOCK_ELEVATE_NAME, {locked: Locks.isArrowLockedRef, modifier: ModifierTracker.ELEVATE_NAME},
        KeyProfile.ARROWLOCK_CONTROL_NAME, {locked: Locks.isArrowLockedRef, modifier: ModifierTracker.CONTROL_NAME},
        KeyProfile.CAPSLOCK_NAME, {locked: Locks.isCapsLockedRef, modifier: KeyProfile.DEFAULT_NAME},
        KeyProfile.NUMLOCK_NAME, {locked: Locks.isNumLockedRef, modifier: KeyProfile.DEFAULT_NAME},
        KeyProfile.MOUSE_NAME, {locked: Locks.isMouseLockedRef, modifier: KeyProfile.DEFAULT_NAME}
    )

    ; - Generic Swapping -

    static _SwapMap => Map(
        "arrow", ObjBindMethod(Locks, "SwapArrow"),
        "caps", ObjBindMethod(Locks, "SwapCaps"),
        "num", ObjBindMethod(Locks, "SwapNum"),
        "mouse", ObjBindMethod(Locks, "SwapMouse"),
        "compad", ObjBindMethod(Locks, "Swapcompatibility"),
        "real", ObjBindMethod(Locks, "SwapReal")
    )

    static Swap(lock_name) {
        if !Locks._SwapMap.Has(lock_name) {
            throw ValueError("lock_name (" lock_name ") is not a valid lock name")
        }
        Locks._SwapMap[lock_name].Call()
    }

    ; - Arrow -

    static isArrowLocked := true
    static isArrowLockedRef {
        get => Locks.isArrowLocked
        set => Locks.isArrowLocked := value
    }
    static SetArrowLocked(bool) {
        ; change and show
        Locks.isArrowLocked := bool
        Badge.ShowBadge(
            "Move with Arrow: " Key.BoolToText[bool],
            Locks.BADGE_SIDE,
            (bool ? Locks.ON_COLOR : Locks.OFF_COLOR)
        )
    }
    static SwapArrow() => Locks.SetArrowLocked(!Locks.isArrowLocked)

    ; - Caps -

    static isCapsLocked := false
    static isCapsLockedRef {
        get => Locks.isCapsLocked
        set => Locks.isCapsLocked := value
    }
    static SetCapsLocked(bool) {
        ; change and show
        Locks.isCapsLocked := bool
        Badge.ShowBadge(
            "Caps Lock: " Key.BoolToText[bool],
            Locks.BADGE_SIDE,
            (bool ? Locks.ON_COLOR : Locks.OFF_COLOR)
        )
    }
    static SwapCaps() => Locks.SetCapsLocked(!Locks.isCapsLocked)

    ; - Num -

    static isNumLocked := false
    static isNumLockedRef {
        get => Locks.isNumLocked
        set => Locks.isNumLocked := value
    }
    static SetNumLocked(bool) {
        ; change and show
        Locks.isNumLocked := bool
        Badge.ShowBadge(
            "Num Lock: " Key.BoolToText[bool],
            Locks.BADGE_SIDE,
            (bool ? Locks.ON_COLOR : Locks.OFF_COLOR)
        )
    }
    static SwapNum() => Locks.SetNumLocked(!Locks.isNumLocked)

    ; - Mouse -

    static isMouseLocked := false
    static isMouseLockedRef {
        get => Locks.isMouseLocked
        set => Locks.isMouseLocked := value
    }
    static SetMouseLocked(bool) {
        ; change and show
        Locks.isMouseLocked := bool
        Badge.ShowBadge(
            "Mouse Lock: " Key.BoolToText[bool],
            Locks.BADGE_SIDE,
            (bool ? Locks.ON_COLOR : Locks.OFF_COLOR)
        )
    }
    static SwapMouse() => Locks.SetMouseLocked(!Locks.isMouseLocked)

    ; - compatibility -
    static iscompatibility := false
    static Setcompatibility(bool, showBadge := true) {
        ; change and show
        Locks.iscompatibility := bool

        ; show badge
        if (showBadge) {
            Badge.ShowBadge(
                "Compad Mode: " Key.BoolToText[bool],
                Locks.BADGE_SIDE,
                (bool ? Locks.ON_COLOR : Locks.OFF_COLOR)
            )
        }
    }
    static Swapcompatibility(showBadge := true) => Locks.Setcompatibility(!Locks.iscompatibility, showBadge)

    ; - Real -

    static isReal := false
    static _real_disincludes => [
        "PrintScreen",
        ModifierTracker.ALT_NAME
    ]
    static SetReal(bool, showBadge := true) {
        ; swap bool
        Locks.isReal := bool

        ; swap behvaior
        if (bool == true) { ; if setting to on
                            ; set all disincludes to true (on)
                            ; set all else to false (off) explicitly
            Key.SetKeys(true, Locks._real_disincludes, false, true)
        } else { ; if setting to off
                 ; set back to current profile settingss
            Profile.SetExceptions(Profile.Curr)
        }

        ; show badge extra logic
        if (showBadge) {
            ; show the badge
            Badge.ShowBadge(
                "Real: " Key.BoolToText[Locks.isReal],
                "Left",
                Locks.isReal ? "450000" : Badge.COLOR_BACKGROUND,
                Locks.isReal ? "C50000" : Badge.COLOR_FOREGROUND
            )
        }
    }
    static SwapReal(showBadge := true) => Locks.SetReal(!Locks.isReal, showBadge)
    
}