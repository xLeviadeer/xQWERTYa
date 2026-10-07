#Requires AutoHotkey v2.0

#Include ../tools/Badge.ahk
#Include ../tools/Utils.ahk
#Include ../tools/Checks.ahk
#Include ../tools/JSON.ahk
#Include LockList.ahk
#Include LockComposition.ahk
#Include ../../config/locks/LockActions.ahk

; delete when not using weird partial implementation
#Include ../key/KeyProfile.ahk

class Lock {
    
    ; - PARTIAL IMPLEMENTATION LOGIC -
    static AccessMap := unset
    static _SwapMap := unset
    static Swap(lock_name) {
        if !Lock._SwapMap.Has(lock_name) {
            throw ValueError("lock_name (" lock_name ") is not a valid lock name")
        }
        Lock._SwapMap[lock_name].Call()
    }

    ; --- VARIABLES ----

    ; -- Static --

    static LOCKS_PATH => "config/locks/locks.json"
    static BADGE_SIDE => "Right"
    static BADGE_ON_COLOR_BG => "A5D2A5"
    static BADGE_OFF_COLOR_BG => "D2A5A5"

    static COMPAD_NAME => "compad"

    static List := LockList()
    static Priority := unset
    static _UsedNames := unset 

    ; -- Instance --

    ;constructed Name
    ;constructed Priority

    ;constructed IsLocked
    ;constructed StartsLocked

    ;constructed IsBindable

    ;constructed _ChangeActionName
    ChangeAction {
        get {
            if (this._ChangeActionName == false) {
                return false
            }
            if !LockActions.HasProp(this._ChangeActionName) {
                throw ValueError("Actions does not contain a method named ⸉" this._ChangeActionName "⸉")
            }
            return (bool) => LockActions.%this._ChangeActionName%(bool)
        }
    }
    
    ;constructed ShowBadge

    ;constructed _BadgeText
    BadgeText {
        get {
            if this._BadgeText != false {
                return this._BadgeText ": "
            }
            return this.Name ": "
        }
    }
    
    ;constructed _BadgeSide
    BadgeSide {
        get {
            if this._BadgeSide != false {
                return this._BadgeSide
            }
            return Lock.BADGE_SIDE
        }
    }

    ;constructed _BadgeOnColor
    BadgeOnColor {
        get {
            if this._BadgeOnColor != false {
                return this._BadgeOnColor
            }
            return Badge.COLOR_FOREGROUND
        }
    }

    ;constructed _BadgeOffColor
    BadgeOffColor {
        get {
            if this._BadgeOffColor != false {
                return this._BadgeOffColor
            }
            return Badge.COLOR_FOREGROUND
        }
    }

    ;constructed _BadgeOnColorBg
    BadgeOnColorBg {
        get {
            if this._BadgeOnColorBg != false {
                return this._BadgeOnColorBg
            }
            return Lock.BADGE_ON_COLOR_BG
        }
    }

    ;constructed _BadgeOffColorBg
    BadgeOffColorBg {
        get {
            if this._BadgeOffColorBg != false {
                return this._BadgeOffColorBg
            }
            return Lock.BADGE_OFF_COLOR_BG
        }
    }

    ; - partial implementation logic -
    IsLockedRef() {
        return this.IsLocked
    }

    ; --- CONSTRUCTOR --- 

    static init() {
        ; check if locks.json exists & priority
        if (FileExist(Lock.LOCKS_PATH)) {
            Lock.List := Map(
                Lock.COMPAD_NAME, Lock( ; compad
                    Lock.COMPAD_NAME, -1,
                    false, false, ; off by default ╎ not bindable
                    false, true, ; no change action ╎ show badge
                    "Compad Mode" 
                )
            )
            for name, value in JSON.LoadFile(LockList, Lock.LOCKS_PATH, "UTF-8") {
                Lock.List[name] := value
            }
        }
        ; create list without un-bindables ╎ excludes un-bindables from the priority
        bindables := Map()
        for name, value in Lock.List {
            if value.IsBindable {
                bindables[name] := value 
            }
        }
        Lock.Priority := Utils.OrderByPriority(bindables)

        ; used names
        Lock._UsedNames := Map()
        for name, value in Lock.List {
            ; duplicates
            if Lock._UsedNames.Has(name) {
                throw ValueError("cannot use name ⸉" name "⸉ because it has already been used")
            }
            Lock._UsedNames[name] := false
        }

        ; - partial implementation logic -
        Lock.AccessMap := Map(
            "arrowlock", {locked: (*) => Lock.List["arrow"].IsLockedRef(), modifier: KeyProfile.DEFAULT_NAME},
            "arrowlock_shift", {locked: (*) => Lock.List["arrow"].IsLockedRef(), modifier: Modifier.SHIFT_NAME},
            "arrowlock_shift_control", {locked: (*) => Lock.List["arrow"].IsLockedRef(), modifier: "shift_control"},
            "arrowlock_elevate", {locked: (*) => Lock.List["arrow"].IsLockedRef(), modifier: Modifier.ELEVATE_NAME},
            "arrowlock_control", {locked: (*) => Lock.List["arrow"].IsLockedRef(), modifier: Modifier.CONTROL_NAME},
            "capslock", {locked: (*) => Lock.List["caps"].IsLockedRef(), modifier: KeyProfile.DEFAULT_NAME},
            "numlock", {locked: (*) => Lock.List["num"].IsLockedRef(), modifier: KeyProfile.DEFAULT_NAME},
            "mouselock", {locked: (*) => Lock.List["mouse"].IsLockedRef(), modifier: KeyProfile.DEFAULT_NAME}
        )
        Lock._SwapMap := Map(
            "arrow", ObjBindMethod(Lock.List["arrow"], "Swap"),
            "caps", ObjBindMethod(Lock.List["caps"], "Swap"),
            "num", ObjBindMethod(Lock.List["num"], "Swap"),
            "mouse", ObjBindMethod(Lock.List["mouse"], "Swap"),
            "compad", ObjBindMethod(Lock.List["compad"], "Swap"),
            "real", ObjBindMethod(Lock.List["real"], "Swap")
        ) 
    }

    __New(
        name,
        priority := -1,
        is_locked := false,
        is_bindable := true,
        change_action_name := false, ; false as do-nothing
        show_badge := true,
        badge_text := false, ; false as default: use the name
        badge_side := false, ; false as default
        badge_on_color := false, ; false as default
        badge_off_color := false, ; false as default
        badge_on_color_bg := false, ; false as default
        badge_off_color_bg := false ; false as default
    ) {
        ; name
        if !(name is String) {
            throw TypeError("name must be a string")
        }
        this.Name := name

        ; priority
        if !(priority is Integer) {
            throw TypeError("priority must be an integer")
        }
        this.Priority := priority

        ; is locked
        Checks.CheckBool(is_locked)
        this.IsLocked := is_locked
        this.StartsLocked := is_locked

        ; is bindable
        Checks.CheckBool(is_bindable)
        this.IsBindable := is_bindable

        ; change action name
        if (
            (change_action_name != false)
            && !(change_action_name is String)
        ) {
            throw TypeError("change_action_name (of " name ") must be a String")
        }
        this._ChangeActionName := change_action_name

        ; show badge
        Checks.CheckBool(show_badge)
        this.ShowBadge := show_badge

        ; badge text
        if (
            (badge_text != false)
            && !(badge_text is String)
        ) {
            throw TypeError("badge_text must be a String")
        }
        this._BadgeText := badge_text

        ; badge side
        if (
            (badge_side != false)
            && (
                !(badge_side is String)
                || !(Badge.position_names.Has(badge_side))
            )
        ) {
            throw TypeError("badge_side must be a valid badge side string")
        }
        this._BadgeSide := badge_side

        ; badge on color
        if (
            (badge_on_color != false)
            && !(badge_on_color is String)
        ) {
            throw TypeError("badge_on_color must be a string")
        }
        this._BadgeOnColor := badge_on_color

        ; badge off color
        if (
            (badge_off_color != false)
            && !(badge_off_color is String)
        ) {
            throw TypeError("badge_off_color must be a string")
        }
        this._BadgeOffColor := badge_off_color

        ; badge on color bg
        if (
            (badge_on_color_bg != false)
            && !(badge_on_color_bg is String)
        ) {
            throw TypeError("badge_on_color_bg must be a string")
        }
        this._BadgeOnColorBg := badge_on_color_bg

        ; badge off color bg
        if (
            (badge_off_color_bg != false)
            && !(badge_off_color_bg is String)
        ) {
            throw TypeError("badge_off_color_bg must be a string")
        }
        this._BadgeOffColorBg := badge_off_color_bg
    }

    ; --- FUNCTIONS ---

    SetLocked(bool, show_badge := unset) {
        ; change and run action
        this.IsLocked := bool
        if this.ChangeAction != false {
            this.ChangeAction.Call(bool)
        }
        
        ; fix show_badge and show
        if !IsSet(show_badge) {
            show_badge := this.ShowBadge
        }
        if show_badge {
            Badge.ShowBadge(
                this.BadgeText Utils.BoolToText[bool],
                this.BadgeSide,
                (bool ? this.BadgeOnColorBg : this.BadgeOffColorBg),
                (bool ? this.BadgeOnColor : this.BadgeOffColor)
            )
        }
    }

    Swap(show_badge := unset) => this.SetLocked(!this.IsLocked, show_badge?)
    
    ; --- COMPOSITION ---

    static CreateCompositionSnapshot() {
        comp := LockComposition()
        for name, value in Lock.List {
            if value.IsLocked {
                comp.Add(name)
            }
        }
        return comp
    }

    ; --- VALIDATION ---

    ; checks if a string is a valid lock
    static CheckValidLock(str) {
        if !(
            (str is String)
            && (Lock.List.Has(str))
        ) {
            throw ValueError("⸉" str "⸉ is not a valid lock name")
        }
    }

    ; --- SERIALIZABLE ---

    static toJSON(lock) => Map(
        "name", lock.Name,
        "priority", lock.Priority,
        "starts_locked", lock.StartsLocked,
        "bindable", lock.is_bindable,
        "change_action", lock._ChangeActionName,
        "show_badge", lock.ShowBadge,
        "badge_text", lock._BadgeText,
        "badge_side", lock._BadgeSide,
        "badge_on_color", lock._BadgeOnColor,
        "badge_off_color", lock._BadgeOffColor,
        "badge_on_color_bg", lock._BadgeOnColorBg,
        "badge_off_color_bg", lock._BadgeOffColorBg
    )
    toJSON() => Lock.toJSON(this)

    static fromJSON(map) {
        return Lock(
            map["name"],
            map.Has("priority") ? map["priority"] : -1,
            map.Has("starts_locked") ? map["starts_locked"] : false,
            map.Has("bindable") ? map["bindable"] : true,
            map.Has("change_action") ? map["change_action"] : false,
            map.Has("show_badge") ? map["show_badge"] : true,
            map.Has("badge_text") ? map["badge_text"] : false,
            map.Has("badge_side") ? map["badge_side"] : false,
            map.Has("badge_on_color") ? map["badge_on_color"] : false,
            map.Has("badge_off_color") ? map["badge_off_color"] : false,
            map.Has("badge_on_color_bg") ? map["badge_on_color_bg"] : false,
            map.Has("badge_off_color_bg") ? map["badge_off_color_bg"] : false
        )
    }
}