#Include Key.ahk
#Include ../modifier/Modifier.ahk
#Include ../lock/Lock.ahk
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
        upKeysymbolLen := StrLen(Modifier.UP_KEYSYMBOL_LONG)
        cutLength := 0
        is_up := false
        if (
            (hotkeyStringLen > upKeysymbolLen) ; long enough to contain " Up"
            && (SubStr( ; ends with " Up"
                HotkeyString, 
                hotkeyStringLen - (upKeysymbolLen - 1),
                hotkeyStringLen
            ) == Modifier.UP_KEYSYMBOL_LONG)
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
    modifier_name => this.modifier.GetNameString(this.is_up)
    modifier_name_down => this.modifier.GetNameString(false)
    modifier_name_up => this.modifier.GetNameString(true)
    _ModifierExists(
        modifier_name := true, ; true = do default
        nonexistent_value := true, ; whether to consider nonexistent
        is_up := this.is_up ; only applies if modifier name was not given
    ) {
        ; default modifier name
        if (modifier_name == true) {
            modifier_name := this.modifier.GetNameString(is_up)
        }

        ; return check if modifier exists
        ; MsgBox(modifier_name)
        ; MsgBox(this.curr_profile_id)
        return (
            this._ProfileRefExists() ; profile exists
            && (this.curr_profile_ref.HasProp(modifier_name)) ; modifier exists
            && (this.curr_profile_ref.%modifier_name% != nonexistent_value) ; modifier isn't true
        )
    }
    modifier_value  => this._get_modifier_value()
    _get_modifier_value(mod_comp := true) { ; true as default
        ; default modifier name
        if mod_comp == true {
            mod_comp := this.modifier
        }

        ; get the value respective to up generation
        if this.do_up_gen {
            return this.curr_profile_ref.%mod_comp.GetNameString(false)% ; down
        } else {
            return this.curr_profile_ref.%mod_comp.GetNameString(this.is_up)% ; up or down
        }
    }

    ; - lock -

    lock_name {
        get {
            if this.lock_select != false {
                return this.lock_select
            }
            return KeyModifier.DEFAULT_NAME ; default if nothing selected
        }
    }
    lock_select := false ; expected to be a string lock combination correlate
    
    lock_value {
        get {
            ; if false: return false ╎ acts like `"my_modifier": { "my_anything": false }`
            if this.modifier_value == false {
                return false
            }

            ; accounts for ⌄
            ;   `do_up_gen` ¡selection¡ 🝗 not value generation 𐑶 in `modifer_value` 
            ;   `lock_select` in `lock_name`
            val := this.modifier_value.%this.lock_name%

            ; account for `do_up_gen` generation
            if this.do_up_gen { 
                return this._generate_up_action(val)
            } else {
                return val
            }
        }
    }

    ; - is_up -

    ;constructed is_up;
    do_up_gen := false
    _generate_up_action(down_value) { ; expects a value string
        ; boolean check & signifier check
        is_bool := Checks.IsBool(down_value)
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
            return stub Modifier.UP_KEYSYMBOL_LONG "}" 
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
            return "{" down_value Modifier.UP_KEYSYMBOL_LONG "}" 
        }
        throw ValueError("cannot convert a complex down action to an automatically generated up action: " down_value " on " this.curr_key_name)
    }

    ; - cancelled -

    ; cancelled should be set when the regular execution of an action should not continue 
        ; an example is when "else" occurs and windows actions have been sent
    cancelled := false

    ; --- CONSTRUCTOR ---

    ; sets the starting point for this execution
    __New(
        key_name, ; expects key_name to be a valid string key name
        profile_id, ; expects profile_id to be a valid string profile name
        modifier, ; expects modifier to be a ModifierComposition
        lock, ; expects lock to be a LockComposition
        is_up ; expects is_up to be a boolean
    ) {
        this.curr_key_name := key_name
        this.curr_profile_id := profile_id
        this.modifier := modifier
        this.original_modifier := modifier.Copy() ; tracked for completing the originally pressed modifier rather than what the modifier is resolved to
        this.lock := lock
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
            Modifier.CreateCompositionSnapshot(), ; snapshot of currently held keys
            Lock.CreateCompositionSnapshot(), ; snapshot of currently active locks
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
        lock_val := this.lock_value
        if (
            (lock_val == false)
            || (lock_val == true)
        ) {
            return ; do nothing
        } else if (lock_val is String) {            
            ; string with no contents, do nothing
            if (StrLen(lock_val) <= 0) {
                return
            }

            ; set mut copy
            modifier_value_adj := lock_val

            ; down prefix
            first_char := SubStr(lock_val, 1, 1)
            if (first_char == Key.DOWN_PREFIX) {
                ; if it's an up bind
                if (this.is_up) { ; set to no longer down
                    Key.DownTracking[this.curr_key_name] := false

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
                
                modifier_value_adj := SubStr(lock_val, 2)
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
                Lock.Swap(modifier_value_no_first)
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
            lock_val.Call(this.curr_key_name)
        }
    }

    ; --- SIGNIFIERS ---

    ; checks for if this string is a signifier
    ;   returns
    ;       true — if signifier
    ;       false — if ⊰not⊱ signifier
    _checkSignifiers(lock_val) {
        ; for each signifier
        for (sig_name, sig_func in this._signifier_map) {
            if (lock_val == sig_name) {
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
            ModifierComposition(), ; empty modifiers
            this.lock,
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
        modifier_base := this.modifier.GetSignificantString()
        if (!this._ModifierExists(modifier_base, true)) {
            throw ValueError("attempting to use base signifier to a key which does not have a base")
        }

        ; run a new action using this modifier (will allow for inheritance and such)
        KeyAction(
            this.curr_key_name, 
            Profile.Curr, 
            ModifierComposition(modifier_base), ; base modifier
            this.lock,
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
        if (Lock.List[Lock.COMPAD_NAME].IsLocked) { ; compability on
            ; dont run for down actions test
            if (!this.is_up) {
                return
            }

            ; for pressed modifiers
            for (modifier_name, mod in Modifier.List) {
                ; try to get reg state
                try {
                    physical_state := GetKeyState(mod.symbol, "P")
                } catch {
                    return
                }

                ; try to get alt state
                try {
                    physical_state_alt := GetKeyState(mod.symbol_alt, "P")
                } catch {
                    return
                }
                
                ; check if states match
                virtual_state := mod.isDown
                if (
                    (physical_state != virtual_state)
                    && (physical_state_alt != virtual_state)
                ) {
                    mod.panic()
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

    ; finds a valid modifier on the provided KeyModifier* ⧼via mod_name⧽ 
        ; changes do_up_gen — only on break return
        ; changes lock_select — only on break return
        ; may return outer loop control signals ⧼intended to be interpretted⧽
            ; true when Break should be used
            ; false when Normal should be used

    _FindLock(mod_comp := true) { ; true as default
        ; default mod_name 
        if mod_comp == true {
            mod_comp := this.modifier
        }

        if !this._ModifierExists(mod_comp.GetNameString(this.is_up)) { ; modifier does not exist
            if ( ; ⓘ up bind does not exist, but down bind does
                this.is_up ; is up bind
                && this._ModifierExists(mod_comp.GetNameString(false)) ; down bind exist
            ) {
                this.do_up_gen := true
                ; don't break out of function
            } else {
                return false
                ; modifier (and down bind if this is an up bind) do not exist, normal
            }
        }
        ; modifier must exist or down binding for this non-existent up binding

        ; break if false
        if this._get_modifier_value(mod_comp) == false {
            return true
            ; this signals to process `"my_modifier": false`
        }
        ; modifier must be a KeyModifier because the contract with KeyProfile means
            ; • true → non-existent ⌃⌃
            ; • false → we just broke ^
            ; • KeyModifier → ⌄

        ; check that locks should be looped
        largest_matching_combo := false
        if (
            (this.lock.Length > 0) ; at least one lock active
            && (this._get_modifier_value(mod_comp).locks != false) ; there are any locks to loop
        ) { 
            ; loop through all lock combinations on this modifier
            for lock_name, lock_value in this._get_modifier_value(mod_comp).locks {
                curr_comp := LockComposition().fromString(lock_name)
                
                ; check if the curr composition does ¡not¡ fit in the active comp: skip
                if !this.lock.Composes(curr_comp) {
                    continue
                }

                ; check if the the composed composition is larger than the existing largest: set largest
                if (
                    (largest_matching_combo == false)
                    || (curr_comp.Length > largest_matching_combo.Length)
                ) {
                    largest_matching_combo := curr_comp
                    continue
                }

                ; if equal length
                if curr_comp.Length == largest_matching_combo.Length {
                    ; use priority to resolve the best match
                    ; zip both comps
                    loop curr_comp.Length {
                        curr_ponet := curr_comp[A_Index]
                        largest_ponet := largest_matching_combo[A_Index]

                        ; if both are the same: skip
                        if curr_ponet == largest_ponet { ; faster to compare strings than look up priority
                            continue
                        }

                        ; set highest of two and break
                        if Lock.RelPriorityOf(curr_ponet) > Lock.RelPriorityOf(largest_ponet) {
                            largest_matching_combo := curr_comp
                            break
                        } else {
                            ; no change
                            break
                        }
                    }
                }
            }
        }
        ; highest found combo will exist at this point as ⌄
        ;   false — if there was nothing to search, or the search could not find any matches
        ;   a composition — if anything was searched that was composed in the active locks

        ; if no matches were found
        if largest_matching_combo == false {
            ; check if default exists to be collapsed into
            if this._get_modifier_value(mod_comp).default != false { ; exists
                return true 
                ; this signals to process `"my_modifier": { "default": ⌯ }
            } else { ; does not exist
                this.do_up_gen := false
                ; disabled in-case it was enabled earlier for searching ╎ it is no longer relevant and should be disabled
                return false
                ; continue like the modifier does not exist (it essentially does not)
            }
            ; all options return meaning an else block does not need to follow
        }

        ; highest found combo must be an existing combination at this point
        this.lock_select := largest_matching_combo.GetNameString()
        return true
        ; signals to process `"my_modifier": { "my_lock": ⌯ }
    }

    ; checks if the modifier doesn't exists
    ;   key — unchanged
    ;   profile — unchanged
    ;   modifier — unchanged
    ;   returns
    ;       Break — when the modifier and valid lock both exist
    ;       Normal — when modifier doesn't exist or the lock does not exist
    _ModifierExistsCheck() {
        if this._FindLock() {
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
            && this._ModifierExists(this.modifier.GetSignificantString()) ; has base
        ) {
            ; check new comp for valid lock
            new_comp := ModifierComposition(this.modifier.GetSignificantString())
            if this._FindLock(new_comp) {
                ; `lock_select` & `do_up_gen` will be set in `_FindLock`
                this.modifier := new_comp
                return KeyActionProcessing.Break ; since we know a valid lock was found we can break here
            }
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
        if (this.curr_profile_is_default) {
            collapse_true_on_profile := Profile.DEFAULT_COLLAPSE
        } else {
            collapse_true_on_profile := this.curr_profile.collapse
        }

        collapse_false_on_profile_ref := (this.curr_profile_ref.%KeyProfile.COLLAPSE_NAME% == false)

        failure_condition := (
            ( ; false on both profile and profile ref
                (!collapse_true_on_profile)
                && collapse_false_on_profile_ref
            ) || ( ; true on profile but explicitly set to false on profile
                collapse_true_on_profile
                && this.curr_profile_ref.collapse_explicit
                && collapse_false_on_profile_ref
            )
        )

        if (
            (this.modifier_name_down != KeyProfile.DEFAULT_NAME) ; is not default modifier already
            && (!failure_condition) ; no fail conditions
        ) {
            empty_comp := ModifierComposition()
            if this._FindLock(empty_comp) {
                ; `lock_select` & `do_up_gen` will be set in `_FindLock`.
                this.modifier.Clear() ; sets to default
                return KeyActionProcessing.Break
            }
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
        if (this.curr_profile_is_default) {
            else_true_on_profile := Profile.DEFAULT_ELSE
        } else {
            else_true_on_profile := this.curr_profile.else
        }

        else_false_on_profile_ref := (this.curr_profile_ref.%KeyProfile.ELSE_NAME% == false)

        failure_condition := ( ; false on both profile and profile ref
            (!else_true_on_profile)
            && else_false_on_profile_ref
        ) || ( ; true on profile but explicitly set to false on profile
            else_true_on_profile
            && this.curr_profile_ref.else_explicit
            && else_false_on_profile_ref
        )

        if (!failure_condition) { ; no fail conditions
            ; run the else action
            this._RunElse()

            ; some kind of keypress will be executed, so it will always be cancelled and we always break
            this.cancelled := true
            return KeyActionProcessing.Break
        }
        return KeyActionProcessing.Normal
    }

    ; - modifier still doesn't exist, profile still could be default -

    ; checks if uses is set
    ;   key — if uses is set,
    ;       set to the uses key
    ;   profile — unchanged
    ;   modifier — unchanged
    ;   returns
    ;       Continue — when uses was set
    ;       Normal — when else
    _UsesCheck() {
        ; deprecated because I don't think this can ever run because modifier cannot exist via the prior check 
            ; will be removed later after testing
        ; if (this._ModifierExists()) { ; if this modifier exists, skip this step
        ;     return KeyActionProcessing.Normal
        ; }
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

    ; - modifier still doesn't exist, profile still could be default -

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

        ; if default profile (cannot inherit, must have explicitly not collapsed or based) do nothing and quit
        if (this.curr_profile_is_default) {
            this.cancelled := true
            return KeyActionProcessing.Break
        }

        ; run profile based inheritance
        this.curr_profile_id := this.curr_profile.inheritsFrom
        return KeyActionProcessing.Continue
    }
}
