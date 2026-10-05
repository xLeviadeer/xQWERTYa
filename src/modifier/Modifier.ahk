#include ../Key/Key.ahk
#Include ../key/KeyProfile.ahk
#Include ../Profile/Profile.ahk
#Include ../tools/List.ahk
#Include ../tools/JSON.ahk
#Include ../../config/modifiers/Actions.ahk

; tracks and manages the state of virtual modifiers
class Modifier {

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
    static UP_KEYSYMBOL_LONG => " " Modifier.UP_KEYSYMBOL

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
        Modifier.SHIFT_NAME,
        Modifier.CONTROL_NAME,
        Modifier.CURL_NAME,
        Modifier.ALT_NAME,
        Modifier.ELEVATE_NAME,
        Modifier.SHELVE_NAME,
        Modifier.STEP_NAME,
		Modifier.WINDOWS_NAME
	]

    static NAME_TO_SYMBOL => Map(
        KeyProfile.DEFAULT_NAME, "",
        Modifier.WINDOWS_NAME, Modifier.WINDOWS_SYMBOL,
        Modifier.STEP_NAME, Modifier.STEP_SYMBOL,
		Modifier.SHELVE_NAME, Modifier.SHELVE_SYMBOL, 
		Modifier.ELEVATE_NAME, Modifier.ELEVATE_SYMBOL, 
		Modifier.ALT_NAME, Modifier.ALT_SYMBOL, 
		Modifier.CURL_NAME, Modifier.CURL_SYMBOL, 
		Modifier.CONTROL_NAME, Modifier.CONTROL_SYMBOL, 
		Modifier.SHIFT_NAME, Modifier.SHIFT_SYMBOL 
    )

    static SYMBOL_TO_NAME => Map(
        "", KeyProfile.DEFAULT_NAME,
        Modifier.WINDOWS_SYMBOL, Modifier.WINDOWS_NAME,
        Modifier.STEP_SYMBOL, Modifier.STEP_NAME,
        Modifier.SHELVE_SYMBOL, Modifier.SHELVE_NAME,
        Modifier.ELEVATE_SYMBOL, Modifier.ELEVATE_NAME,
        Modifier.ALT_SYMBOL, Modifier.ALT_NAME,
        Modifier.CURL_SYMBOL, Modifier.CURL_NAME,
        Modifier.CONTROL_SYMBOL, Modifier.CONTROL_NAME,
        Modifier.SHIFT_SYMBOL, Modifier.SHIFT_NAME
    )

    static STANDARD_NAME_TO_SYTACTICAL => Map( ; PROBLEMATIC
        Modifier.WINDOWS_NAME, "#",
        Modifier.ALT_NAME, "!",
        Modifier.CONTROL_NAME, "^",
        Modifier.SHIFT_NAME, "+"
    )

    ; - mappings -

    static List := List()
    static Symbols() {
        targets := []
        for (name, value in Modifier.List) {
            targets.Push(value.symbol)
        }
        return targets
    }
    ; --- INIT ---

    static init() => Modifier.List := List(
        ; shift
        Modifier.SHIFT_NAME, Modifier(
            Modifier.SHIFT_NAME,
            Modifier.SHIFT_SYMBOL
        ),

        ; control
        Modifier.CONTROL_NAME, Modifier(
            Modifier.CONTROL_NAME,
            Modifier.CONTROL_SYMBOL
        ),

        ; curl
        Modifier.CURL_NAME, Modifier(
            Modifier.CURL_NAME,
            Modifier.CURL_SYMBOL,
            ,
            ,
            "CapsLockOff",
            "CapsLockOff"
        ),

        ; alt
        Modifier.ALT_NAME, Modifier(
            Modifier.ALT_NAME,
            Modifier.ALT_SYMBOL,
        ),

        ; elevate
        Modifier.ELEVATE_NAME, Modifier(
            Modifier.ELEVATE_NAME,
            Modifier.ELEVATE_SYMBOL,
        ),

        ; shelve
        Modifier.SHELVE_NAME, Modifier(
            Modifier.SHELVE_NAME,
            Modifier.SHELVE_SYMBOL,
            [Modifier.SHELVE_SYMBOL_ALT]
        ),

        ; step
        Modifier.STEP_NAME, Modifier(
            Modifier.STEP_NAME,
            Modifier.STEP_SYMBOL
        ),

        ; windows
        Modifier.WINDOWS_NAME, Modifier(
            Modifier.WINDOWS_NAME,
            Modifier.WINDOWS_SYMBOL,
            ,
            "Windows"
        )
    )

    ; --- Bind ---

    static BindAll() {
        for (modifier_name, modifier_value in Modifier.List) {
            ; bind down
            combination := Modifier.ConstructCombination(modifier_name, modifier_value.symbol)
            Hotkey(combination, ObjBindMethod(Modifier, "_TrackKey", modifier_name, false))
            Key.UsedCombinations[modifier_name] := combination
            
            ; bind up 
            combination_up := combination Modifier.UP_KEYSYMBOL_LONG
            Hotkey(combination_up, ObjBindMethod(Modifier, "_TrackKey", modifier_name, true))
            Key.UsedCombinations[modifier_name Modifier.UP_KEYNAME] := combination_up   

            ; if has alts
            if (modifier_value.hasAlt) {
                for alt in modifier_value.symbol_alts {
                    ; bind down
                    combination := Modifier.ConstructCombination(modifier_name, alt)
                    Hotkey(combination, ObjBindMethod(Modifier, "_TrackKey", modifier_name, false))
                    Key.UsedCombinations[modifier_name] := combination
                    
                    ; bind up 
                    combination_up := combination Modifier.UP_KEYSYMBOL_LONG
                    Hotkey(combination_up, ObjBindMethod(Modifier, "_TrackKey", modifier_name, true))
                    Key.UsedCombinations[modifier_name Modifier.UP_KEYNAME] := combination_up   
                }
            }
        }
    }

    ; -- Instance --

    ;constructed name;
    ;constructed symbol;
    ;constructed symbol_alts;
    hasAlt => this.symbol_alts != false
    isDown := false
    completed := false

    ;constructed lone_action_name;
    ;constructed down_action_name;
    ;constructed up_action_name;
    lone_action {
        get {
            if (this.lone_action_name == false) {
                return false
            }
            if !Actions.HasProp(this.lone_action_name) {
                throw ValueError("Actions does not contain a method named ⸉" this.lone_action_name "⸉")
            }
            return () => Actions.%this.lone_action_name%()
        }
    }
    down_action {
        get {
            if (this.down_action_name == false) {
                return false
            }
            if !Actions.HasProp(this.down_action_name) {
                throw ValueError("Actions does not contain a method named ⸉" this.down_action_name "⸉")
            }
            return () => Actions.%this.down_action_name%()
        }
    }
    up_action {
        get {
            if (this.up_action_name == false) {
                return false
            }
            if !Actions.HasProp(this.up_action_name) {
                throw ValueError("Actions does not contain a method named ⸉" this.up_action_name "⸉")
            }
            return () => Actions.%this.up_action_name%()
        }
    }

    ; --- CONSTRUCTOR ---

    __New(
        name, 
        symbol, 
        symbol_alts := false,
        lone_action_name := false,
        down_action_name := false,
        up_action_name  := false
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
        if (symbol_alts != false) {
            if !(symbol_alts is Array) {
                throw TypeError("symbol_alts (of " name ") must be a an array of keys")
            }
            for str in symbol_alts {
                if (GetKeySC(str) == 0) { ; not a real key
                    throw TypeError("at least one value in symbol_alts (of " name ") was not a valid key")
                }
            }
        }
        this.symbol_alts := symbol_alts

        ; check name
        if !(name is String) {
            throw TypeError("name must be a string: " Type(name))
        }
        this.name := name

        ; check lone_action_name
        if (
            (lone_action_name != false)
            && !(lone_action_name is String)
        ) {
            throw TypeError("lone_action_name (of " name ") must be a String")
        }
        this.lone_action_name := lone_action_name

        ; check down_action_name
        if (
            (down_action_name != false)
            && !(down_action_name is String)
        ) {
            throw TypeError("down_action_name (of " name ") must be a String")
        }
        this.down_action_name := down_action_name

        ; check up_action_name
        if (
            (up_action_name != false)
            && !(up_action_name is String)
        ) {
            throw TypeError("up_action_name (of " name ") must be a String")
        }
        this.up_action_name := up_action_name
    }

    ; --- DETERMINE ACTION ---

    static _TrackKey(name, is_up_action, tk) {
        ; get tracked key
        tracked_key := Modifier.List[name]

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
        SendInput("{Blind}{" this.symbol Modifier.DOWN_KEYSYMBOL_LONG "}")
        SendInput("{Blind}{" this.symbol Modifier.UP_KEYSYMBOL_LONG "}")
    }

    ; --- PASSTHROUGH ---

    static ConstructSymbol(symbol) => Modifier.ALL_PREFIX Modifier.SAFTEY_PREFIX symbol

    static ConstructPassthrough(name) {
        if (Profile.Curr == Profile.DEFAULT_NAME) {
            return (Profile.DEFAULT_MODIFIER_PASSTHROUGH[name] ? Modifier.PASSTHROUGH_SYMBOL : "")
        } else {
            return (Profile.GetPassthrough(Profile.Curr)[name] ? Modifier.PASSTHROUGH_SYMBOL : "")
        }
    }

    static ConstructCombination(
        name, 
        symbol := Modifier.List[name].symbol
    ) => (
        Modifier.ConstructPassthrough(name) 
        Modifier.ConstructSymbol(symbol)
    )

    static UpdatePassthrough(name, bool) {
        ; check it's a real modifer
        if !(Modifier.List.Has(name)) {
            throw ValueError("'" name "' is not a valid modifier name")
        }
        symbol := Modifier.List[name].symbol

        Hotkey(
            (bool ? Modifier.PASSTHROUGH_SYMBOL : "")
            Modifier.ConstructSymbol(symbol)
        )
    }

    ; --- COMPOSITION ---

    static CreateCompositionSnapshot() {
        comp := ModifierComposition()
        for (modifier_name, modifier_value in Modifier.List) {
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
			&& (Modifier.List.Has(str))
		) {
			throw ValueError("'" str "' is not a valid modifier name")
		}
	} 

    ; --- SERIALIZABLE ---

    static toJSON(mod) => Map(
        "name", mod.name,
        "symbol", mod.symbol,
        "alternates", mod.symbol_alts,
        "lone_action", mod.lone_action_name,
        "down_action", mod.down_action_name,
        "up_action", mod.up_action_name
    )
    toJSON() => Modifier.toJSON(this)

    static fromJSON(map) {
        return Modifier(
            map["name"],
            map["symbol"],
            map.Has("alternates") ? map["alternates"] : false,
            map.Has("lone_action") ? map["lone_action"] : false,
            map.Has("down_action") ? map["down_action"] : false,
            map.Has("up_action") ? map["up_action"] : false
        )
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

	Add(mod) {
		Modifier.CheckValidModifier(mod)
        if (this.List.Count == 1) { 
            this.Significant := mod 
        }
		this.List[mod] := false
		this.changed := true
	}

	Remove(mod) {
        Modifier.CheckValidModifier(mod)
		this.List.Remove(mod)
		this.changed := true
	}

    Clear() {
        this.List.Clear()
        this.changed := true
    }

    ; does NOT validate the modifier name
    static ModifierOf(modifier_name) => Modifier.List[modifier_name]

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
                for (mod in Modifier.PRIORITY) {
                    if (this.List.Has(mod)) {
                        composition_str := (
                            composition_str 
                            (isFirstModifier ? "" : Modifier.MODIFIER_JOIN)
                            mod
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
            (is_up ? Modifier.UP_KEYNAME : "")
        )
	}

    GetSyntacticalString() { ; PROBLEMATIC
        syntactical_modifiers := ""
        for (modifier_name in this.List) {
            if (Modifier.STANDARD_NAME_TO_SYTACTICAL.Has(modifier_name)) {
                syntactical_modifiers := syntactical_modifiers Modifier.STANDARD_NAME_TO_SYTACTICAL[modifier_name]
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
                Modifier.NAME_TO_SYMBOL[modifier_name] 
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