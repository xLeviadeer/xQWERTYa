#Include Key.ahk
#Include Modifier.ahk
#Include CustomKeys.ahk

; class that describes a key event
class KeyEvent {

    ; --- VARIABLES ---

    ;constructed key_target;
    ;constructed is_up;

    ; --- CONSTRUCTOR ---

    __New(
        key_target,
        is_up
    ) {
        this.key_target := key_target
        this.is_up := is_up
    }

    static FromHotkeyString(HotkeyString) {
        ; match positions out of the hotkey name
        RegExMatch(
            HotkeyString,
            "^(?!.*\+.*\+)(?!.*\$.*\$)[\*\$]+",
            &info
        )
        splitPosition := 0
        if (info is RegExMatchInfo) {
            splitPosition := info.Len
        }

        ; check if it's an up action
        hotkeyStringLen := StrLen(HotkeyString)
        upKeysymbolLen := StrLen(ModifierTracker.UP_KEYSYMBOL_LONG)
        cutLength := 0
        is_up := false
        if (
            (hotkeyStringLen > upKeysymbolLen) ; long enough to contain " Up"
            && (SubStr( ; ends with " Up"
                HotkeyString, 
                hotkeyStringLen - (upKeysymbolLen - 1),
                hotkeyStringLen
            ) == ModifierTracker.UP_KEYSYMBOL_LONG)
        ) {
            cutLength := upKeysymbolLen
            is_up := true
        }

        ; get the key name out of the hotkey name
        key_target := SubStr(
            HotkeyString,
            splitPosition + 1,
            (hotkeyStringLen - (splitPosition - 1)) - (cutLength + 1)
        )

        ; return new
        return KeyEvent(key_target, is_up)
    }
}

; (enum) holds constants for KeyAction processing
class KeyActionProcessing {
    static Normal => 0
    static Continue => 1
    static Break => 2
} 

StrOccur(haystack, needle) {
    return StrSplit(haystack, needle).Length - 1
}

; code for determining an action to execute when a key is pressed
class KeyAction {

    ; --- VARIABLES ---

    ; -- Static --

    ; list of actions to execute for checking
    DETERMINATION_ORDER => [
        this._LocksCheck, ; will break if needed on the first enumeration 
        this._ProfileExistsCheck,
        this._ModifierExistsCheck,
        this._BasedCheck,
        this._CollapseCheck,
        this._ElseCheck,
        this._UsesCheck,
        this._InheritsCheck
    ]
    static RAW_SIGNIFIER => "~"
    static COLLAPSE_SIGNIFIER => "ⓝcollapse"
    static ELSE_SIGNIFIER => "ⓝelse"
    static BASE_SIGNIFIER => "ⓝbase"
    static CYCLE_SIGNIFIER => "ⓝcycle"
    static RELOAD_SIGNIFIER => "ⓝreload"
    static KILL_SIGNIFIER => "ⓝkill"

    ; -- Instance --

    ; - key -

    ;constructed curr_key_name;
    curr_key => Key.List[this.curr_key_name]

    ; - profile -

    ;constructed curr_profile_id;
    curr_profile {
        get {
            if (this.curr_profile_is_default) {
                return false ; fail whatever action is attempted
            } 
            return Profile.List[this.curr_profile_id]
        }
    }
    curr_profile_is_default => this.curr_profile_id == Profile.DEFAULT_NAME

    ; - profile_ref -

    _ProfileRefExists() => this.curr_key.profiles.Has(this.curr_profile_id)
    curr_profile_ref => this.curr_key.profiles[this.curr_profile_id]

    ; - modifier -

    ;constructed modifier;
    ;constructed original_modifier;
    _get_modifier_name(is_up) {
        if (this.lock_modifier_name) { ; returns lock name if lock is being used
            return this.lock_modifier_name
        }
        return this.modifier.GetNameString(is_up)
    }
    modifier_name => this._get_modifier_name(this.is_up)
    modifier_name_down => this._get_modifier_name(false)
    modifier_name_up => this._get_modifier_name(true)
    _ModifierExists(
        modifier_name := true, ; true = do default
        nonexistent_value := true, ; whether to consider nonexistent
        is_up := this.is_up ; only applies if modifier name was not given
    ) {
        ; default modifier name
        if (modifier_name == true) {
            modifier_name := this._get_modifier_name(is_up)
        }

        ; return check if modifier exists
        return (
            this._ProfileRefExists() ; profile exists
            && (this.curr_profile_ref.HasProp(modifier_name)) ; modifier exists
            && (this.curr_profile_ref.%modifier_name% != nonexistent_value) ; modifier isn't true
        )
    }
    lock_modifier_name := false
    _get_modifier_value() {
        if this.do_up_gen { 
            ; we know that this action must be an up bind with an existing down bind based on the check that sets do_up_gen
            down_value := this.curr_profile_ref.%this.modifier_name_down%

            ; boolean check & signifier check
            is_bool := (
                (down_value == true)
                || (down_value == false)
            )
            is_signifier := this._signifier_map.Has(down_value)
            if (
                is_signifier
                || is_bool
            ) { ; directly use signifier/bool (but with is_up context)
                return down_value
            }

            ; already contains up signal
            is_up_signal := RegExMatch(down_value, "Up(\s*)}")
            if is_up_signal {
                throw ValueError("cannot convert a down action which already signals Down/Up to an automatically generated up action: " down_value " on " this.curr_key_name)
            }
            
            ; convert downs to ups & check if last is already up
            ;   behavioral quirk: would act as follows for converting something like 🜚 {a}{b Down} → {a}{b Up}
            ;   {a} is never assigned because it has no ⸉Down⸉
            down_value := RegExReplace(down_value, "Down(\s*)}", "Up}") ; replace downs with ups if they exist
            last_is_up := (
                (StrLen(down_value) >= 4) ; can contan ⸉ Up}⸉
                && (SubStr(down_value, StrLen(down_value) - 4, StrLen(down_value)) == " Up}")
            )
            if last_is_up {
                return down_value
            }

            ; check for valid container
            is_valid_container := ( 
                (StrLen(down_value) >= 3) ; len 3 or more 🜚 {a}
                && (SubStr(down_value, StrLen(down_value), 1) == "}") ; last == }
            )
            if is_valid_container { ; insert up
                stub := SubStr(down_value, 1, StrLen(down_value) - 1) ; string without } 🜚 {a
                return stub ModifierTracker.UP_KEYSYMBOL_LONG "}" 
            }

            ; check for valid
            is_valid := (
                (StrLen(down_value) >= 1) ; len 1 or more 🜚 a
                && ( ; either { ꭉ } are not included
                    (StrOccur(down_value, "{") == 0) ; no {
                    || (StrOccur(down_value, "}") == 0) ; no }
                )
            )
            if is_valid { ; wrap up
                return "{" down_value ModifierTracker.UP_KEYSYMBOL_LONG "}" 
            }
            throw ValueError("cannot convert a complex down action to an automatically generated up action: " down_value " on " this.curr_key_name)
        }
        return this.curr_profile_ref.%this.modifier_name% ; up or down auto
    }
    do_up_gen := false

    ; - is_up -

    ;constructed is_up;

    ; - cancelled -

    ; cancelled should be set when the regular execution of an action should not continue 
        ; an example is when "else" occurs and windows actions have been sent
    cancelled := false

    ; --- CONSTRUCTOR ---

    ; sets the starting point for this execution
        ; expects key_name to be a valid string key name
        ; expects profile_id to be a valid string profile name
        ; expects modifier to be a ModifierComposition
        ; expects is_up to be a boolean
    __New(key_name, profile_id, modifier, is_up) {
        this.curr_key_name := key_name
        this.curr_profile_id := profile_id
        this.modifier := modifier
        this.original_modifier := modifier.Copy() ; tracked for completing the originally pressed modifier rather than what the modifier is resolved to
        this.is_up := is_up
    }

    ; --- RAW SIGNIFIER HELPER ---

    ; removes the raw signifier and returns whether or not it has raw signifier
    static IsRaw(str, &new_str) {
        if (SubStr(str, 1, 1) == KeyAction.RAW_SIGNIFIER) {
            new_str := SubStr(str, 2, StrLen(str))
            return true
        } 
        new_str := str
        return false
    }

    ; --- EXECUTIONS ---

    ; creates a KeyAction from the hotkeystring and runs it
    static HandleKey(HotkeyString) {
        ; parse the key
        key_event := KeyEvent.FromHotkeyString(HotkeyString)

        ; create a starting point action
        key_action := KeyAction(
            key_event.key_target, ; currently pressed key
            Profile.Curr, ; current profile
            ModifierTracker.CreateCompositionSnapshot(), ; snapshot of currently held keys
            key_event.is_up
        )

        ; run this actiokn
        key_action.Run()
    }

    ; runs this action; executes the appropriate thing for this action
    Run() {
        ; compatibility mode checks
        this._compatibilityMode()

        ; check if the starting profile disables letters
        if (this._DisablesLetters()) {
            this.original_modifier.MarkCompleted()
            return
        }
        
        ; start inheritance loop
        search_for_more_inheritance := true
        while (search_for_more_inheritance) {
            ; make each determination check in order
            for (determination in this.DETERMINATION_ORDER) {
                ; check if the determination flag
                switch determination.Call(this) {
                    case KeyActionProcessing.Normal: ; do nothing
                        continue
                    case KeyActionProcessing.Continue: ; break this loop and continue outer loop
                        break
                    case KeyActionProcessing.Break: ; break this loop and break outer lopp
                        search_for_more_inheritance := false
                        break
                }
            }
        }

        ; check if it's been cancelled
        if (this.cancelled) {
            this.original_modifier.MarkCompleted()
            return
        }

        ; execute
        this._Execute()
        this.original_modifier.MarkCompleted()
    }

    ; executes the action using its current properties as target settings
    _Execute() {
        ; switch based on modifier value
        mod_val := this._get_modifier_value()
        if (
            (mod_val == false)
            || (mod_val == true)
        ) {
            return ; do nothing
        } else if (mod_val is String) {            
            ; string with no contents, do nothing
            if (StrLen(mod_val) <= 0) {
                return
            }

            ; set mut copy
            modifier_value_adj := mod_val

            ; down prefix
            first_char := SubStr(mod_val, 1, 1)
            if (first_char == Key.DOWN_PREFIX) {
                ; if it's an up bind
                if (this.is_up) { ; set to no longer down
                    Key.DownTracking[this.curr_key_name] := false
                    ; deprecated alongside NAMES_DOWN
                    ; for (mod_name in ModifierTracker.NAMES_DOWN) {
                    ;     Key.DownTracking[this.curr_key_name] := false
                    ; }
                    ; continue

                ; track down status
                } else {
                    if (
                        !(Key.DownTracking.Has(this.curr_key_name))
                        || (Key.DownTracking[this.curr_key_name] == false)
                    ) { ; not in the down tracking map or false in the map
                        Key.DownTracking[this.curr_key_name] := true
                        ; continue
                    } else { ; in map and true, do nothing
                        return ; return
                    }
                }
                
                modifier_value_adj := SubStr(mod_val, 2)
                if (StrLen(modifier_value_adj) == 0) {
                    return ; no further action needed, string is now empty
                }
            }
            first_char := SubStr(modifier_value_adj, 1, 1) ; adj for down tracking
            modifier_value_no_first := SubStr(modifier_value_adj, 2) ; remove first char

            ; if any signifiers are present
            if (this._checkSignifiers(modifier_value_adj)) {
                return
            }

            ; mouse button
            if (first_char == Key.MOUSE_PREFIX) { 
                ; split into comma arguments
                    ; button, x, y, count, speed, state, relative
                    ; 🜚 L, , , , , D
                args := StrReplace(modifier_value_no_first, " ", "") ; remove spaces
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
                Profile.SwitchTo(modifier_value_no_first)
                return
            }

            ; lock action
            if (first_char == Key.LOCK_PREFIX) {
                Locks.Swap(modifier_value_no_first)
                return
            }
            
            ; custom action
            if (first_char == Key.ACTION_PREFIX) { 
                custom_target := CustomKeys.List[this.curr_key_name]
                function_name := modifier_value_no_first
                if !(custom_target.HasMethod(function_name)) {
                    throw ValueError("function not in targeted CustomKey reference; '" function_name "' is not a valid function")
                }
                custom_target.%function_name%.Call(modifier_value_no_first)
                return
            } 

            ; check blind
            if (this.curr_profile_is_default) {
                do_blind := Profile.DEFAULT_BLIND
            } else {
                do_blind := this.curr_profile.blind
            }

            ; adjust for blind
            blinded_modifier_value := (do_blind) ? "{Blind}" modifier_value_adj : modifier_value_adj
            
            ; text
            SendInput(blinded_modifier_value)
        } else {
            mod_val.Call(this.curr_key_name)
        }
    }

    ; --- SIGNIFIERS ---

    ; checks for if this string is a signifier
    ;   returns
    ;       true — if signifier
    ;       false — if ⊰not⊱ signifier
    _checkSignifiers(mod_val) {
        ; for each signifier
        for (sig_name, sig_func in this._signifier_map) {
            if (mod_val == sig_name) {
                return sig_func.Call(this)
            }
        }
        return false
    }

    ; signifiers list
    _signifier_map := Map(
        KeyAction.COLLAPSE_SIGNIFIER, this._sigCollapse,
        KeyAction.ELSE_SIGNIFIER, this._sigElse,
        KeyAction.BASE_SIGNIFIER, this._sigBase,
        KeyAction.CYCLE_SIGNIFIER, this._sigCycle,
        KeyAction.RELOAD_SIGNIFIER, this._sigReload,
        KeyAction.KILL_SIGNIFIER, this._sigKill
    )

    ; collapse
    _sigCollapse() {
        ; clear modifiers 
        this.modifier.Clear() ; sets to default

        ; run a new key action using this modifier
        KeyAction(
            this.curr_key_name,
            Profile.Curr,
            ModifierComposition(),
            this.is_up
        ).Run()
        return true
    }

    ; else
    _sigElse() {
        this._RunElse()
        return true
    }

    ; base
    _sigBase() {
        ; check if this is a base
        if (!this.modifier.IsTripleBind) {
            throw ValueError("base signifier cannot be used on a single or double bind")
        }

        ; check if a base doesn't exist
        modifier_base := this.modifier.Significant
        if (!this._ModifierExists(modifier_base, true)) {
            throw ValueError("attempting to use base signifier to a key which does not have a base")
        }

        ; run a new action using this modifier (will allow for inheritance and such)
        KeyAction(
            this.curr_key_name, ; same pressed key
            Profile.Curr, ; current profile
            ModifierComposition(modifier_base), ; base modifier
            this.is_up
        ).Run()
        return true
    }

    ; cycle
    _sigCycle() {
        Profile.Cycle() 
        return true
    }

    ; reload 
    _sigReload() {
        Badge.ShowBadge(
            "Reloading the program",
            "Middle",
            "996300",
            "ffA500"
        )
        ; as long as this isn't instant then `this.modifier.MarkCompleted()` doesn't need to be run early (which is the only thing that has to finalize before closing the program)
        SetTimer(() => Reload(), -Badge.TOOLTIP_TIME_MS)
        return true
    }

    ; kill
    _sigKill() {
        Key.SetKeys(false) ; disable all binds to prevent glitches when turning off
        Badge.ShowBadge(
            "Exited the program",
            "Middle",
            "460026",
            "FF0000"
        )
        ; as long as this isn't instant then `this.modifier.MarkCompleted()` doesn't need to be run early (which is the only thing that has to finalize before closing the program)
        SetTimer(() => ExitApp(), -Badge.TOOLTIP_TIME_MS)
        return true
    }

    ; --- DETERMINATIONS ---

    ; this must be tracked here because it needs to happen on ⊰any⊱ keypress, not just modifier keypresses

    ; checks for a virtual modifier state which doesn't match a physical state and corrects it
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — unchanged
    _compatibilityMode() {
        if (Locks.iscompatibility) { ; compability on
            ; dont run for down actions test
            if (!this.is_up) {
                return
            }

            ; for pressed modifiers
            for (modifier_name, modifier in ModifierTracker.List) {
                ; try to get reg state
                try {
                    physical_state := GetKeyState(modifier.symbol, "P")
                } catch {
                    return
                }

                ; try to get alt state
                try {
                    physical_state_alt := GetKeyState(modifier.symbol_alt, "P")
                } catch {
                    return
                }
                
                ; check if states match
                virtual_state := modifier.isDown
                if (
                    (physical_state != virtual_state)
                    && (physical_state_alt != virtual_state)
                ) {
                    modifier.panic()
                }
            }
        }
    }

    ; checks if the current action should disable letters
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — unchanged
    ;   returns
    ;       true — when this action should be cancelled
    ;       false — when this action shouldn't be cancelled
    _DisablesLetters() {
        if (
            !(this.curr_profile_is_default)
            && (this.curr_profile.disablesLetters)
            && (Key.IsLetterKey(this.curr_key_name))
        ) {
            if !(this.is_up) { ; don't run press counting for up actions 
                if (Key.letterPressCount < Key.letterPressRequirement) {
                    Key.addLetterPress()
                    Badge.ShowBadge(
                        "No letters profile: (" Key.letterPressCount "/" Key.letterPressRequirement ")",
                        "Middle",
                        Badge.COLOR_BACKGROUND,
                        "C50000"
                    )
                    SetTimer(ObjBindMethod(Key, "subLetterPress"), -Key.letterPressTime)
                } else {
                    Profile.SwitchTo(Profile.DEFAULT_NAME)
                    Badge.ShowBadge(
                        "Default re-enabled",
                        "Middle",
                        "FFD5D5",
                        "FF0000"
                    )
                }
            }
            return true ; yes, disable letters for this action
        }
        return false ; no, don't disable letters for this action
    }

    ; adjusts the modifier for locks
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — if locked and lock existst on action,
    ;       set to the associated lock modifier
    ;   returns
    ;       Break — when locked and lock existst on action
    ;       Normal — when else
    _LocksCheck() {
        ; check all locks
        for lock_name, lock_value in Locks.AccessMap {
            ; check if the current lock (access) modifier is NOT the same as the currently held modifier(s)
            if (lock_value.modifier == this.modifier_name) {
                ; check if the matching lock is locked
                if (
                    lock_value.locked ; is locked
                    && this._ModifierExists(lock_name) ; lock exists on this action
                ) {
                    ; set lock modifier
                    this.lock_modifier_name := lock_name

                    ; break — stops looking for inheritance
                        ; this makes these statements only valid at toplevel
                    return KeyActionProcessing.Break
                }
            } ; continue
        }
        return KeyActionProcessing.Normal
    }

    ; - recurring processing starts -

    ; checks if the profile reference exists on this action
    ;   key — unchanged
    ;   profile — if nonexistent,
    ;       set to the inherited profile (from profile definition, defaults as default)
    ;   modifier — unchanged
    ;   returns
    ;       Continue — when nonexistent
    ;       Normal — else
    _ProfileExistsCheck() {
        if !(this._ProfileRefExists()) {
            if (this.curr_profile_is_default) {
                throw ValueError("default profile reference doesn't exist on this key: '" this.curr_profile_id "'")
            }
            this.curr_profile_id := this.curr_profile.inheritsFrom
            return KeyActionProcessing.Continue
        }
        return KeyActionProcessing.Normal
    }

    ; - profile definitely exists at this point, but could be default -

    ; checks if the modifier doesn't exists
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — unchanged
    ;   returns
    ;       Break — when modifier exists
    ;       Normal — when modifier doesn't exist
    _ModifierExistsCheck() {
        if this._ModifierExists() { ; modifier exists
            return KeyActionProcessing.Break
        }
        if ( ; (bind does not exist)
            this.is_up ; is up bind
            && this._ModifierExists(, , false) ; down bind exist
        ) {
            this.do_up_gen := true ; do up generation for value gets of this key
            return KeyActionProcessing.Break
        }
        return KeyActionProcessing.Normal
    }

    ; - modifier definitely doesn't exist at this point, profile still could be default - 

    ; checks if based is present and bases if it's an unset triple bind
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — if unset triple bind with an existing base,
    ;       set to base
    ;   return 
    ;       Continue — when unset triple bind with existing base
    ;       Normal — when else
    _BasedCheck() {
        if (this.curr_profile_is_default) {
            based_true_on_profile := Profile.DEFAULT_BASED
        } else {
            based_true_on_profile := this.curr_profile.based
        }

        based_false_on_profile_ref := (this.curr_profile_ref.%KeyProfile.BASED_NAME% == false)

        failure_condition := ( ; profile false & modifier false | does the profile and the key have based off? 
            (!based_true_on_profile) 
            && based_false_on_profile_ref 
        ) || ( ; profile true & modifier false (explicit) | are the profile and the profile ref both false and explicitly set as false?
            based_true_on_profile 
            && this.curr_profile_ref.based_explicit
            && based_false_on_profile_ref
        )

        if (
            this.modifier.IsTripleBind ; only for triple binds
            && (!failure_condition) ; no fail conditions
            && this._ModifierExists(this.modifier.Significant) ; has base
        ) {
            this.modifier := ModifierComposition(this.modifier.Significant)
            return KeyActionProcessing.Continue
        }
        return KeyActionProcessing.Normal
    }

    ; - modifier definitely doesn't exist at this point, profile still could be default - 

    ; checks if collapse is present and collapses to default
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — if collapse is present,
    ;       set to the default modifier
    ;   returns
    ;       Continue — when collapse is present
    ;       Normal — when collapse is not present
    _CollapseCheck() {
        ; somehow having comments is a syntax error, so I have to do it like this
        ; if (
        ;   (this.modifier_name_down != KeyProfile.DEFAULT_NAME) ; not default already
        ;   && (
        ;       (
        ;           this.curr_profile_is_default ; true if default
        ;           && (!( ; was not explicitly set to false
        ;               this.curr_profile_ref.collapse_explicit ; collapse was explicitly set
        ;              && (this.curr_profile_ref.%KeyProfile.COLLAPSE_NAME% == false) ; collapse is false
        ;          ))
        ;      )
        ;      || this._ModifierExists(KeyProfile.COLLAPSE_NAME, false) ; collapse exists and is true
        ;   )
        ; )
        if (
            (this.modifier_name_down != KeyProfile.DEFAULT_NAME) 
            && (
                (
                    this.curr_profile_is_default 
                    && (!( 
                        this.curr_profile_ref.collapse_explicit 
                        && (this.curr_profile_ref.%KeyProfile.COLLAPSE_NAME% == false) 
                    ))
                )
                || this._ModifierExists(KeyProfile.COLLAPSE_NAME, false)
            )
        ) {
            this.modifier.Clear() ; sets to default
            return KeyActionProcessing.Continue
        }
        return KeyActionProcessing.Normal
    }

    ; - modifier definitely doesn't exist at this point, profile still could be default - 

    ; helper for running else actions on the current key action
    _RunElse() {
        ; check if up action exists on this action
        upActionExists := (this._ModifierExists(this.modifier_name_up))
                
        ; determine what key to press
        elsed_modifier_input := false
        if (!this.is_up) { ; down action
            if !(upActionExists) {
                elsed_modifier_input := this.modifier.GetInputString(this.curr_key_name, "Down")
            } else {
                elsed_modifier_input := this.modifier.GetInputString(this.curr_key_name, "Inspecific")
            }
        } else { ; up action
            if !(upActionExists) {
                elsed_modifier_input := this.modifier.GetInputString(this.curr_key_name, "Up")
            } ; do nothing
        }

        ; send input
        if (elsed_modifier_input != false) {
            SendInput(elsed_modifier_input)
        }
    }

    ; checks if else is present and runs the default window action
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — unchanged
    ;   returns
    ;       Break — when else is present
    ;       Normal — when else is not present
    ;   cancels — when else exists
    _ElseCheck() {
        ; somehow having comments is a syntax error, so I have to do it like this
        ; if (
        ;     (
        ;         this.curr_profile_is_default ; true if default
        ;         && (!( ; was not explicitly set to false
        ;             this.curr_profile_ref.else_explicit ; else was explicitly set
        ;             && (this.curr_profile_ref.%KeyProfile.ELSE_NAME% == false) ; else is false
        ;         ))
        ;     )
        ;     || this._ModifierExists(KeyProfile.ELSE_NAME, false) ; else exists
        ; )
        if (
            (
                this.curr_profile_is_default 
                && (!( 
                    this.curr_profile_ref.else_explicit 
                    && (this.curr_profile_ref.%KeyProfile.ELSE_NAME% == false) 
                ))
            )
            || this._ModifierExists(KeyProfile.ELSE_NAME, false) 
        ) {
            ; run the else action
            this._RunElse()

            ; some kind of keypress will be executed, so it will always be cancelled and we always break
            this.cancelled := true
            return KeyActionProcessing.Break
        }
        return KeyActionProcessing.Normal
    }

    ; - modifier still doesn't exist, but profile cannot be default anymore -

    ; checks if uses is set
    ;   key — if uses is set,
    ;       set to the uses key
    ;   profile — unchanged
    ;   modifier — unchanged
    ;   returns
    ;       Continue — when uses was set
    ;       Normal — when else
    _UsesCheck() {
        if (this._ModifierExists()) { ; if this modifier exists, skip this step
            return KeyActionProcessing.Normal
        }
        at_least_one_found := false

        ; if there's a uses╌read it
        prosp_key_name := false
        if (this._ModifierExists(KeyProfile.USES_NAME)) {
            prosp_key_name := this.curr_profile_ref.%KeyProfile.USES_NAME%
            KeyAction.IsRaw(prosp_key_name, &prosp_key_name)
            at_least_one_found := true
        }

        ; if there's a uses profile╌read it
        prosp_profile_id := false
        if (this._ModifierExists(KeyProfile.USES_PROFILE_NAME)) {
            prosp_profile_id := this.curr_profile_ref.%KeyProfile.USES_PROFILE_NAME%
            KeyAction.IsRaw(prosp_profile_id, &prosp_profile_id)
            at_least_one_found := true
        }

        ; run process for uses key
        if (prosp_key_name != false) {
            ; check if the uses string is a valid key
            if !(Key.List.Has(prosp_key_name)) {
                throw ValueError("'" prosp_key_name "' is not a valid key to use")
            } 
            this.curr_key_name := prosp_key_name
        }

        ; run process for uses profile
        if (prosp_profile_id != false) {
            ; check if the uses string is a valid key
            if (
                (prosp_profile_id != Profile.DEFAULT_NAME)
                && !(Profile.List.Has(prosp_profile_id))
            ) {
                throw ValueError("'" prosp_profile_id "' is not a valid profile to use")
            } 
            this.curr_profile_id := prosp_profile_id
        }

        ; continue if at least one found, else normal
        if (at_least_one_found) {
            return KeyActionProcessing.Continue
        }
        return KeyActionProcessing.Normal
    }

    ; - modifier still doesn't exist and profile cannot be default -

    ; check if inherits_from is set
    ;   key — unchanged
    ;   profile — if inherits_from is set,
    ;       set to the inherits_from profile
    ;   modifier — unchanged
    ;   returns
    ;       Continue — when inherits_from was set
    ;       Normal — when else
    _InheritsCheck() {
        ; check for key based inheritance
        if (this._ModifierExists(KeyProfile.INHERITS_FROM_NAME)) {
            ; check if the inherits from string is a valid profile
            prosp_profile_name := this.curr_profile_ref.%KeyProfile.INHERITS_FROM_NAME%
            if (
                (prosp_profile_name != Profile.DEFAULT_NAME)
                && !(Profile.List.Has(prosp_profile_name))
            ) {
                throw ValueError("'" prosp_profile_name "' is not a valid profile to use")
            }
            this.curr_profile_id := prosp_profile_name
            return KeyActionProcessing.Continue
        }

        ; run profile based inheritance
        this.curr_profile_id := this.curr_profile.inheritsFrom
        return KeyActionProcessing.Continue
    }
}
