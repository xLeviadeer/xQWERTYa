#include ../Key/Key.ahk
#Include ../key/KeyProfile.ahk
#Include ../Profile/Profile.ahk
#Include ../../config/modifiers/Curl.ahk
#Include ../../config/modifiers/Windows.ahk

; tracks and manages the state of virtual modifiers
class ModifierTracker {

    ; --- VARIABLES ---

    ; -- static --

    static MODIFIERS_PATH => "config/modifiers/modifiers.json"

    ; - prefixes -

    static PASSTHROUGH_SYMBOL => "~"
    static ALL_PREFIX => "*"
    static SAFTEY_PREFIX => "$"
    static MODIFIER_JOIN => "_"

    ; - up -
    
    static UP_KEYNAME => "_up"
    static UP_KEYSYMBOL => "Up"
    static UP_KEYSYMBOL_LONG => " " ModifierTracker.UP_KEYSYMBOL

    ; - down -

    static DOWN_KEYSYMBOL_LONG => " Down"

    ; - names/symbols -
    
    ; scan codes list found here: https://learn.microsoft.com/en-us/windows/win32/inputdev/about-keyboard-input
    ; sharp keys releases here: https://github.com/randyrants/sharpkeys/releases

    static SHIFT_NAME => "shift"
    static SHIFT_SYMBOL => "LShift"

    static CONTROL_NAME => "control"
    static CONTROL_SYMBOL => "LCtrl"

    static CURL_NAME => "curl"
    static CURL_SYMBOL => "CapsLock"

    static ALT_NAME => "alt"
    static ALT_SYMBOL => "RAlt"

    static ELEVATE_NAME => "elevate"
    static ELEVATE_SYMBOL => "LAlt" 

    static SHELVE_NAME => "shelve"
    static SHELVE_SYMBOL => "LWin" 
    static SHELVE_SYMBOL_ALT => "SC070"

    static STEP_NAME => "step"
    static STEP_SYMBOL => "SC073"

    static WINDOWS_NAME => "windows"
    static WINDOWS_SYMBOL => "RCtrl"

	; - priority order - 

	static PRIORITY => [
        ModifierTracker.SHIFT_NAME,
        ModifierTracker.CONTROL_NAME,
        ModifierTracker.CURL_NAME,
        ModifierTracker.ALT_NAME,
        ModifierTracker.ELEVATE_NAME,
        ModifierTracker.SHELVE_NAME,
        ModifierTracker.STEP_NAME,
		ModifierTracker.WINDOWS_NAME
	]

    static SYMBOLS => [
        ModifierTracker.WINDOWS_SYMBOL,
        ModifierTracker.STEP_SYMBOL,
        ModifierTracker.SHELVE_SYMBOL,
        ModifierTracker.ELEVATE_SYMBOL,
        ModifierTracker.ALT_SYMBOL,
        ModifierTracker.CURL_SYMBOL,
        ModifierTracker.CONTROL_SYMBOL,
        ModifierTracker.SHIFT_SYMBOL
    ]

    static NAME_TO_SYMBOL => Map(
        KeyProfile.DEFAULT_NAME, "",
        ModifierTracker.WINDOWS_NAME, ModifierTracker.WINDOWS_SYMBOL,
        ModifierTracker.STEP_NAME, ModifierTracker.STEP_SYMBOL,
		ModifierTracker.SHELVE_NAME, ModifierTracker.SHELVE_SYMBOL, 
		ModifierTracker.ELEVATE_NAME, ModifierTracker.ELEVATE_SYMBOL, 
		ModifierTracker.ALT_NAME, ModifierTracker.ALT_SYMBOL, 
		ModifierTracker.CURL_NAME, ModifierTracker.CURL_SYMBOL, 
		ModifierTracker.CONTROL_NAME, ModifierTracker.CONTROL_SYMBOL, 
		ModifierTracker.SHIFT_NAME, ModifierTracker.SHIFT_SYMBOL 
    )

    static SYMBOL_TO_NAME => Map(
        "", KeyProfile.DEFAULT_NAME,
        ModifierTracker.WINDOWS_SYMBOL, ModifierTracker.WINDOWS_NAME,
        ModifierTracker.STEP_SYMBOL, ModifierTracker.STEP_NAME,
        ModifierTracker.SHELVE_SYMBOL, ModifierTracker.SHELVE_NAME,
        ModifierTracker.ELEVATE_SYMBOL, ModifierTracker.ELEVATE_NAME,
        ModifierTracker.ALT_SYMBOL, ModifierTracker.ALT_NAME,
        ModifierTracker.CURL_SYMBOL, ModifierTracker.CURL_NAME,
        ModifierTracker.CONTROL_SYMBOL, ModifierTracker.CONTROL_NAME,
        ModifierTracker.SHIFT_SYMBOL, ModifierTracker.SHIFT_NAME
    )

    static STANDARD_NAME_TO_SYTACTICAL => Map( ; PROBLEMATIC
        ModifierTracker.WINDOWS_NAME, "#",
        ModifierTracker.ALT_NAME, "!",
        ModifierTracker.CONTROL_NAME, "^",
        ModifierTracker.SHIFT_NAME, "+"
    )

    ; - list —

    static List := unset
    static init() => ModifierTracker.List := Map(
        ; shift
        ModifierTracker.SHIFT_NAME, ModifierTracker(
            ModifierTracker.SHIFT_NAME,
            ModifierTracker.SHIFT_SYMBOL
        ),

        ; control
        ModifierTracker.CONTROL_NAME, ModifierTracker(
            ModifierTracker.CONTROL_NAME,
            ModifierTracker.CONTROL_SYMBOL
        ),

        ; curl
        ModifierTracker.CURL_NAME, ModifierTracker(
            ModifierTracker.CURL_NAME,
            ModifierTracker.CURL_SYMBOL,
            ,
            ,
            () => Curl.CapsLockOff(),
            () => Curl.CapsLockOff()
        ),

        ; alt
        ModifierTracker.ALT_NAME, ModifierTracker(
            ModifierTracker.ALT_NAME,
            ModifierTracker.ALT_SYMBOL,
        ),

        ; elevate
        ModifierTracker.ELEVATE_NAME, ModifierTracker(
            ModifierTracker.ELEVATE_NAME,
            ModifierTracker.ELEVATE_SYMBOL,
        ),

        ; shelve
        ModifierTracker.SHELVE_NAME, ModifierTracker(
            ModifierTracker.SHELVE_NAME,
            ModifierTracker.SHELVE_SYMBOL,
            ModifierTracker.SHELVE_SYMBOL_ALT
        ),

        ; step
        ModifierTracker.STEP_NAME, ModifierTracker(
            ModifierTracker.STEP_NAME,
            ModifierTracker.STEP_SYMBOL
        ),

        ; windows
        ModifierTracker.WINDOWS_NAME, ModifierTracker(
            ModifierTracker.WINDOWS_NAME,
            ModifierTracker.WINDOWS_SYMBOL,
            ,
            () => Windows.Windows()
        )
    )

    ; --- Bind ---

    static BindAll() {
        for (modifier_name, modifier_value in ModifierTracker.List) {
            ; bind down
            combination := ModifierTracker.ConstructCombination(modifier_name, modifier_value.symbol)
            Hotkey(combination, ObjBindMethod(ModifierTracker, "_TrackKey", modifier_name, false))
            Key.UsedCombinations[modifier_name] := combination
            
            ; bind up 
            combination_up := combination ModifierTracker.UP_KEYSYMBOL_LONG
            Hotkey(combination_up, ObjBindMethod(ModifierTracker, "_TrackKey", modifier_name, true))
            Key.UsedCombinations[modifier_name ModifierTracker.UP_KEYNAME] := combination_up   

            ; if has alts
            if (modifier_value.hasAlt) {
                ; bind down
                combination := ModifierTracker.ConstructCombination(modifier_name, modifier_value.symbol_alt)
                Hotkey(combination, ObjBindMethod(ModifierTracker, "_TrackKey", modifier_name, false))
                Key.UsedCombinations[modifier_name] := combination
                
                ; bind up 
                combination_up := combination ModifierTracker.UP_KEYSYMBOL_LONG
                Hotkey(combination_up, ObjBindMethod(ModifierTracker, "_TrackKey", modifier_name, true))
                Key.UsedCombinations[modifier_name ModifierTracker.UP_KEYNAME] := combination_up   
            }
        }
    }

    ; -- Instance --

    ;constructed name;
    ;constructed symbol;
    ;constructed symbol_alt;
    hasAlt => this.symbol_alt != false
    ;constructed lone_action;
    ;constructed down_action;
    ;constructed up_action;
    isDown := false
    completed := false

    ; --- CONSTRUCTOR ---

    __New(
        name, 
        symbol, 
        symbol_alt := false,
        lone_action := false,
        down_action := false,
        up_action := false
    ) {
        ; check that symbol is a real key
        if (
            !(symbol is String)
            || (GetKeySC(symbol) == 0) ; not a real key
        ) {
            throw TypeError("symbol must be a valid key")
        }
        this.symbol := symbol

        ; check that symbol alt is a real key
        if (
            (symbol_alt != false)
            && (
                !(symbol_alt is String)
                || (GetKeySC(symbol_alt) == 0) ; not a real key
            )
        ) {
            throw TypeError("symbol_alt must be a valid key")
        }
        this.symbol_alt := symbol_alt

        ; check name
        if !(name is String) {
            throw TypeError("name must be a string: " Type(name))
        }
        this.name := name

        ; check lone_action
        if (
            (lone_action != false)
            && !(lone_action is Func)
            && !(lone_action is BoundFunc)
        ) {
            throw TypeError("lone_action must be a Func or BoundFunc: " this.name)
        }
        this.lone_action := lone_action

        ; check down_action
        if (
            (down_action != false)
            && !(down_action is Func)
            && !(down_action is BoundFunc)
        ) {
            throw TypeError("down_action must be a Func or BoundFunc")
        }
        this.down_action := down_action

        ; check up_action
        if (
            (up_action != false)
            && !(up_action is Func)
            && !(up_action is BoundFunc)
        ) {
            throw TypeError("up_action must be a Func or BoundFunc")
        }
        this.up_action := up_action
    }

    ; --- DETERMINE ACTION ---

    static _TrackKey(name, is_up_action, tk) {
        ; get tracked key
        tracked_key := ModifierTracker.List[name]

        ; if it's an up action
        if (is_up_action) {
            tracked_key.isDown := false ; mark as no longer down
            
            ; run up action
            if (tracked_key.up_action != false) {
                tracked_key.up_action.Call()
            }

            ; check if the action was not completed to call completion action
            if (
                (!(tracked_key.completed))
                && (tracked_key.lone_action != false)
            ) {
                tracked_key.lone_action.Call()
            }
            tracked_key.completed := false

        ; it's a down action
        } else {
            ; set as down
            tracked_key.isDown := true

            ; run down action
            if (tracked_key.up_action != false) {
                tracked_key.down_action.Call()
            }
        }
    }

    ; --- PANIC ON ---

    Panic() {
        this.isDown := false
        this.completed := true
        SendInput("{Blind}{" this.symbol ModifierTracker.DOWN_KEYSYMBOL_LONG "}")
        SendInput("{Blind}{" this.symbol ModifierTracker.UP_KEYSYMBOL_LONG "}")
    }

    ; --- PASSTHROUGH ---

    static ConstructSymbol(symbol) => ModifierTracker.ALL_PREFIX ModifierTracker.SAFTEY_PREFIX symbol

    static ConstructPassthrough(name) {
        if (Profile.Curr == Profile.DEFAULT_NAME) {
            return (Profile.DEFAULT_MODIFIER_PASSTHROUGH[name] ? ModifierTracker.PASSTHROUGH_SYMBOL : "")
        } else {
            return (Profile.GetPassthrough(Profile.Curr)[name] ? ModifierTracker.PASSTHROUGH_SYMBOL : "")
        }
    }

    static ConstructCombination(
        name, 
        symbol := ModifierTracker.List[name].symbol
    ) => (
        ModifierTracker.ConstructPassthrough(name) 
        ModifierTracker.ConstructSymbol(symbol)
    )

    static UpdatePassthrough(name, bool) {
        ; check it's a real modifer
        if !(ModifierTracker.List.Has(name)) {
            throw ValueError("'" name "' is not a valid modifier name")
        }
        symbol := ModifierTracker.List[name].symbol

        Hotkey(
            (bool ? ModifierTracker.PASSTHROUGH_SYMBOL : "")
            ModifierTracker.ConstructSymbol(symbol)
        )
    }

    ; --- COMPOSITION ---

    static CreateCompositionSnapshot() {
        comp := ModifierComposition()
        for (modifier_name, modifier_value in ModifierTracker.List) {
            ; check if the modifier is on
            if (modifier_value.isDown) {
                comp.Add(modifier_name)
            }
        }
        return comp
    }

    ; --- EXTERNAL VALIDATION HELPERS ---

    ; checks if a string is a valid modifier
    static CheckValidModifier(str) {
		if !(
			(str is String)
			&& (ModifierTracker.List.Has(str))
		) {
			throw ValueError("'" str "' is not a valid modifier name")
		}
	} 
}

; holds a composition of virtual modifiers
class ModifierComposition {

	; --- VARIABLES ---

	;constructed List;
    ;constructed Significant;
	;constructed Str;
	changed := true

    Length => this.List.Count

    ; - IsTripleBind -
    IsTripleBind => this.List.Count > 1

	; --- CONSTRUCTOR ---

	__New(v*) {
        ; set modifier helper
        this.List := Map()

		; parse v
        v_length := 0
        for (_ in v) {
            v_length += 1
        }
		if (v_length >= 1) {
			completed := false
			if (v_length == 2) {
				if (v[1] is ModifierComposition) { ; modifier composition copy
					for (modifier, _ in v.List) {
						this.Add(modifier)
					}

					completed := true
				} else if (v[1] is Array) { ; list of values
					for (modifier in v[1]) {
						this.Add(modifier)
					}

					completed := true
				}
			}
			if !(completed) { ; multiple values
				for (modifier in v) {
					this.Add(modifier)
				}
			}
		}
	}

	; --- FUNCTIONS ---

	Add(modifier) {
		ModifierTracker.CheckValidModifier(modifier)
        if (this.List.Count == 1) { 
            this.Significant := modifier 
        }
		this.List[modifier] := false
		this.changed := true
	}

	Remove(modifier) {
        ModifierTracker.CheckValidModifier(modifier)
		this.List.Remove(modifier)
		this.changed := true
	}

    Clear() {
        this.List.Clear()
        this.changed := true
    }

    ; does NOT validate the modifier name
    static ModifierOf(modifier_name) => ModifierTracker.List[modifier_name]

    ; --- SIMULATE ---

    ; simulates passthrough for a composition
    ; is_up expects -1, true or false where -1 means ⸉opposite of the current⸉
    SimulatePassthrough(isDown := -1) {
        ; for each modifier in the composition
        for (modifier_name, _ in this.List) {
            ; branch for is_up state
            if (isDown == -1) {
                new_state := !ModifierComposition.ModifierOf(modifier_name).isDown
            } else {
                new_state := isDown
            }

            ; set new state
            if (new_state == true) { ; if state is down, set completed to false
                SendInput(this.GetSendSymbolString("Down"))
            } else {
                SendInput(this.GetSendSymbolString("Up"))
            }
        }
    }

    ; simulates a change of this modifier
    ; is_up expects -1, true or false where -1 means ⸉opposite of the current⸉
    ; do_passthrough controls whether or not to simulate pressing the modifiers in this key to windows
    Simulate(isDown := -1, do_passthrough := false) {
        ; simulate passthrough
        if (do_passthrough) {
            this.SimulatePassthrough(isDown)
        }

        ; for each modifier in the composition
        for (modifier_name, _ in this.List) {
            modifier := ModifierComposition.ModifierOf(modifier_name)

            ; branch for is_up state
            if (isDown == -1) {
                new_state := !modifier.isDown
            } else {
                new_state := isDown
            }

            ; set new state
            modifier.isDown := new_state
            if (new_state == true) { ; if state is down, set completed to false
                modifier.completed := false
            }

            ; run up/down actions
            if (new_state == true) {
                if (modifier.up_action != false) {
                    modifier.up_action.Call()
                }
            } else {
                if (modifier.down_action != false) {
                    modifier.down_action.Call()
                }
            }
        }
    }

	; --- GET STRINGS ---

	GetNameString(is_up) {
		; construct new if needed
        composition_str := ""
		if (this.changed) {
            ; if values
            if (this.List.Count > 0) {
                isFirstModifier := true
                for (modifier in ModifierTracker.PRIORITY) {
                    if (this.List.Has(modifier)) {
                        composition_str := (
                            composition_str 
                            (isFirstModifier ? "" : ModifierTracker.MODIFIER_JOIN)
                            modifier
                        )
                        isFirstModifier := false
                    }
                }
            } else { ; no values
                composition_str := KeyProfile.DEFAULT_NAME
            }
            this.changed := false
            this.Str := composition_str
		} else {
			composition_str := this.Str
		}

        ; add up if needed
        return (
            composition_str
            (is_up ? ModifierTracker.UP_KEYNAME : "")
        )
	}

    GetSyntacticalString() { ; PROBLEMATIC
        syntactical_modifiers := ""
        for (modifier_name in this.List) {
            if (ModifierTracker.STANDARD_NAME_TO_SYTACTICAL.Has(modifier_name)) {
                syntactical_modifiers := syntactical_modifiers ModifierTracker.STANDARD_NAME_TO_SYTACTICAL[modifier_name]
            }
        }
        return syntactical_modifiers
    }

    ; mode is expected to be 'Down' or 'Up' (UNVALIDATED)
    GetSendSymbolString(mode) {
        send_string := ""
        for (modifier_name in this.List) {
            ; add to send_string
            send_string := (
                send_string 
                "{" 
                ModifierTracker.NAME_TO_SYMBOL[modifier_name] 
                " "
                mode
                "}"
            )
        }
        return send_string
    }

    ; input is expected to have no modifiers, as this function will apply modifiers
    ; mode is expected to be 'Down', 'Up' or 'Inspecific' (UNVALIDATED)
    GetInputString(input, mode) {
        ; switch over mode
        switch (mode) {
            case "Inspecific":
                return this.GetSyntacticalString() "{" input "}"
            case "Down":
                return this.GetSyntacticalString() "{" input " Down}"
            case "Up":
                return this.GetSyntacticalString() "{" input " Up}"
        }
    }

    ; --- MARK COMPLETED ---

    MarkCompleted() {
        ; mark all as completed
        for (modifier_name in this.List) {
            ModifierComposition.ModifierOf(modifier_name).completed := true
        }
    }

    ; --- COPY ---

    Copy() {
        return ModifierComposition(this.List*)
    }
}