#Requires AutoHotkey v2.0

#Include ../tools/Checks.ahk
#Include ../tools/Capitalization.ahk

class ActionSignifier {
    ; --- VARIABLES ---

    static List := [
        ActionSignifier("ⓝcollapse", ActionSignifier._Collapse),
        ActionSignifier("ⓝelse", ActionSignifier._Else),
        ActionSignifier("ⓝbase", ActionSignifier._Base),
        ActionSignifier("ⓝcycle", ActionSignifier._Cycle),
        ActionSignifier("ⓝreload", ActionSignifier._Reload),
        ActionSignifier("ⓝkill", ActionSignifier._Kill),
        ActionSignifier("ⓝlower", ActionSignifier._Lower, false),
        ActionSignifier("ⓝupper", ActionSignifier._Upper, false)
    ]
    static _Map := unset

    static Has(signature) => ActionSignifier._Map.Has(signature)

    Signature := unset
    Method := unset
    AllowsUp := unset

    ; --- CONSTRUCTOR ---

    __New(
        signature,
        method,
        allows_up := true
    ) {
        if !(signature is String) {
            throw TypeError("signature must be a string")
        }
        this.Signature := signature

        if (
            !(method is Func)
            && !(method is BoundFunc)
        ) {
            throw TypeError("method must be an AHK function")
        }
        this.Method := method

        Checks.CheckBool(allows_up)
        this.AllowsUp := allows_up
    }

    static init() {
        ActionSignifier._Map := Map()
        for sig in ActionSignifier.List {
            ActionSignifier._Map[sig.Signature] := sig
        }
    }

    ; --- METHODS ---

    ; checks for if a string is a signifier match
    ;   expects
    ;       KeyAction: key_action — a reference to the current process
    ;       action: value — the action value to check against
    ;   returns
    ;       method — if signifier
    ;       false — signaling ⸉no signifier⸉
    ;       true — signaling ⸉do nothing⸉ 
    static CheckAll(key_action, value) {
        ; only check if value is a string
        if !(value is String) {
            return false ; continue | no signifiers
        }

        ; loop signifiers list
        for sig in ActionSignifier.List {
            ; skip if non-match
            if value != sig.Signature {
                continue
            }

            ; stop if unmatched up permission
            if key_action.is_up && !sig.AllowsUp {
                return true ; do nothing
            }

            ; run action
            return sig.Method.Call(this, key_action)
        }
        return false ; continue | no signifiers
    }

    ; --- METHOD LIB ---

    static _Collapse(key_action) {
        ; clear modifiers 
        key_action.modifier.Clear() ; sets to default

        ; run a new key action using key_action modifier
        return KeyAction(
            key_action.curr_key_name,
            Profile.Curr,
            ModifierComposition(), ; empty modifiers
            key_action.lock,
            key_action.is_up
        ).Resolve()
    }

    static _Else(key_action) {
        return key_action._ResolveElse()
    }

    static _Base(key_action) {
        ; check if key_action is a base
        if (!key_action.modifier.IsTripleBind) {
            throw ValueError("base signifier cannot be used on a single or double bind")
        }

        ; check if a base doesn't exist
        modifier_base := key_action.modifier.GetSignificantString()
        if (!key_action._ModifierExists(modifier_base, true)) {
            throw ValueError("attempting to use base signifier to a key which does not have a base")
        }

        ; run a new action using key_action modifier (will allow for inheritance and such)
        return KeyAction(
            key_action.curr_key_name, 
            Profile.Curr, 
            ModifierComposition(modifier_base), ; base modifier
            key_action.lock,
            key_action.is_up
        ).Resolve()
    }

    static _Cycle(key_action) {
        return (target) => Profile.Cycle() 
    }

    static _Reload(key_action) {
        rel() {
            Badge.ShowBadge(
                "Reloading the program",
                "Middle",
                "996300",
                "ffA500"
            )
            ; as long as this isn't instant then `this.modifier.MarkCompleted()` doesn't need to be run early (which is the only thing that has to finalize before closing the program)
            SetTimer(() => Reload(), -Badge.TOOLTIP_TIME_MS)
        }
        return (target) => rel()
    }

    static _Kill(key_action) {
        kill() {
            Key.SetKeys(false) ; disable all binds to prevent glitches when turning off
            Badge.ShowBadge(
                "Exited the program",
                "Middle",
                "460026",
                "FF0000"
            )
            ; as long as this isn't instant then `this.modifier.MarkCompleted()` doesn't need to be run early (which is the only thing that has to finalize before closing the program)
            SetTimer(() => ExitApp(), -Badge.TOOLTIP_TIME_MS)
        }
        return (target) => kill()
    }

    static _Upper(key_action) {
        up(clip_content) {
            capsed_content := Capitalization.ToUpper(clip_content)
            SendText(capsed_content)
        }
        return (target) => Clipboard.UseHighlighted(up)
    }

    static _Lower(key_action) {
        down(clip_content) {
            capsed_content := Capitalization.ToLower(clip_content, true)
            SendText(capsed_content)
        }
        return (target) => Clipboard.UseHighlighted(down)
    }
}