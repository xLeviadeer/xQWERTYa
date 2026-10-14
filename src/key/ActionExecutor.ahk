#Requires AutoHotkey v2.0

class ActionExecutor {
    __New(
        target,
        value,
        is_up,
        do_blind,
        do_down_tracking
    ) {
        this.target := target
        this.value := value
        this.is_up := is_up
        this.do_blind := do_blind
        this.do_down_tracking := do_down_tracking
    }

    Execute(original_modifier) {
        this._Execute()
        original_modifier.MarkCompleted()
    }

    _Execute() {
        ; switch based on modifier value
        if Checks.IsBool(this.value) {
            return ; do nothing
        } else if (this.value is String) {            
            ; down tracking
            if this.do_down_tracking {
                ; if it's an up bind
                if (this.is_up) { ; set to no longer down
                    Key.DownTracking[this.target] := false

                ; track down status
                } else {
                    if (
                        !(Key.DownTracking.Has(this.target))
                        || (Key.DownTracking[this.target] == false)
                    ) { ; not in the down tracking map or false in the map
                        Key.DownTracking[this.target] := true
                        ; continue
                    } else { ; in map and true, do nothing
                        return ; return
                    }
                }
            }

            ; string with no contents, do nothing
            if (StrLen(this.value) <= 0) {
                return
            }

            ; split value
            first_char := SubStr(this.value, 1, 1) ; adj for down tracking
            value_no_first := SubStr(this.value, 2) ; remove first char

            ; mouse button
            if (first_char == Key.MOUSE_PREFIX) { 
                ; split into comma arguments
                    ; button, x, y, count, speed, state, relative
                    ; 🜚 L, , , , , D
                args := StrReplace(value_no_first, " ", "") ; remove spaces
                args := StrSplit(args, ",") ; split by commas
                for (i, arg in args) {
                    if arg == "" {
                        args.Delete(i)
                    }
                }
                MouseClick(args*)
                return
            } 

            ; profile action
            if (first_char == Key.PROFILE_PREFIX) {
                Profile.SwitchTo(value_no_first)
                return
            }

            ; lock action
            if (first_char == Key.LOCK_PREFIX) {
                Lock.Swap(value_no_first)
                return
            }
            
            ; custom action
            if (first_char == Key.ACTION_PREFIX) { 
                custom_target := CustomKeys.List[this.target]
                function_name := value_no_first
                if !(custom_target.HasMethod(function_name)) {
                    throw ValueError("function not in targeted CustomKey reference; '" function_name "' is not a valid function")
                }
                custom_target.%function_name%.Call(value_no_first)
                return
            } 

            ; adjust for blind
            blinded_modifier_value := (this.do_blind) ? "{Blind}" this.value : this.value
            
            ; text
            SendInput(blinded_modifier_value)
        } else {
            this.value.Call(this.target)
        }
    }
}