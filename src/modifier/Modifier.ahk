#include ../Key/Key.ahk
#Include ../key/KeyProfile.ahk
#Include ../Profile/Profile.ahk
#Include ../tools/List.ahk
#Include ../tools/JSON.ahk
#Include ../tools/Composition.ahk
#Include ModifierList.ahk
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

    ; - syntactical -

    static SHIFT_SYNTAX => "+"
    static CONTROL_SYNTAX => "^"
    static ALT_SYNTAX => "!"
    static WINDOWS_SYNTAX => "#"
    static SYNTAXES => Utils.SetOf(
        Modifier.SHIFT_NAME,
        Modifier.CONTROL_SYNTAX,
        Modifier.ALT_SYNTAX,
        Modifier.WINDOWS_SYNTAX
    )
    static SYMBOL_SYNTAX_MAP => Map(
        "LShift", Modifier.SHIFT_SYNTAX,
        "RShift", Modifier.SHIFT_SYNTAX,
        "LCtrl", Modifier.CONTROL_SYNTAX,
        "RCtrl", Modifier.CONTROL_SYNTAX,
        "LAlt", Modifier.ALT_SYNTAX,
        "RAlt", Modifier.ALT_SYNTAX,
        "LWin", Modifier.WINDOWS_SYNTAX,
        "RWin", Modifier.WINDOWS_SYNTAX
    )

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

    ; - mappings -

    static List := ModifierList()
    static Priority := unset
    static RelPriorityOf(mod) { ; assumes valid modifier string mod
        return Utils.IndexOf(Modifier.Priority, mod) ; gives an integer "priority" representing the position of the object not the real priority value
    }
    static Symbols(include_alts := false) {
        targets := []
        for (name, value in Modifier.List) {
            targets.Push(value.symbol)
        }
        return targets
    }
    static SymbolToName := unset
    static UsedSymbols := unset

    ; --- INIT ---

    static init() {
        ; check if modifiers.json exists
        relative_path := Modifier.MODIFIERS_PATH
        if (FileExist(relative_path)) {
            Modifier.List := JSON.LoadFile(ModifierList, relative_path, "UTF-8")
        }

        ; priority & symbol to name & used symbols
        Modifier.Priority := Array()
        Modifier.SymbolToName := Map("", KeyProfile.DEFAULT_NAME)
        Modifier.UsedSymbols := Map()
        for name, value in Modifier.List {
            ; priority
            if (Modifier.Priority.Length == 0) {
                Modifier.Priority.Push(name)
            } else {
                ; adds in increasing priority order not allowing duplicates
                i := 1
                added := false
                for search_name in Modifier.Priority {
                    search_priority := Modifier.List[search_name].priority
                    if (value.priority == search_priority) {
                        throw ValueError("in modifiers.json: two priorities cannot have the same value")
                    }
                    if (search_priority > value.priority) {
                        Modifier.Priority.InsertAt(i, name)
                        added := true
                        break
                    }
                    ; incr
                    i += 1
                }
                if (added == false) {
                    Modifier.Priority.Push(name)
                }
            }

            ; symbol to name
            Modifier.SymbolToName[value.symbol] := name

            ; duplicates
            if Modifier.UsedSymbols.Has(value.symbol) {
                throw ValueError("cannot use target " value.symbol " because it has already been used")
            }
            Modifier.UsedSymbols[value.symbol] := false
            if (value.hasAlt) {
                for alt in value.symbol_alts {
                    if Modifier.UsedSymbols.Has(alt) {
                        throw ValueError("cannot use alternate " alt " because it has already been used")
                    }
                    Modifier.UsedSymbols[alt] := false
                }
            }
        }
    }

    ; -- Instance --

    ;constructed name;
    ;constructed priority;
    ;constructed symbol;
    ;constructed symbol_alts;
    hasAlt => this.symbol_alts != false
    ;constructed else;

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
        priority,
        symbol, 
        symbol_alts := false,
        else_ := false,
        lone_action_name := false,
        down_action_name := false,
        up_action_name  := false
    ) {
        ; check priority is a number
        if !(priority is Integer) {
            throw TypeError("priority must be an integer")
        }
        this.priority := priority

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

        ; check else
        if (
            (else_ != false)
            && (
                !(else_ is String)
                || !(Modifier.SYNTAXES.Has(else_))
            )
        ) {
            throw TypeError("else must be a valid syntax symbol: ⸉" else_ "⸉ when it must be ⸢" Modifier.SHIFT_SYNTAX "⸥, ⸢" Modifier.CONTROL_SYNTAX "⸥, ⸢" Modifier.ALT_SYNTAX "⸥ or ⸢" Modifier.WINDOWS_SYNTAX "⸥")
        }
        this.else := else_

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

    ; - bind -

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

    ; - track -

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
        "priority", mod.priority,
        "symbol", mod.symbol,
        "alternates", mod.symbol_alts,
        "else", mod.else_,
        "lone_action", mod.lone_action_name,
        "down_action", mod.down_action_name,
        "up_action", mod.up_action_name
    )
    toJSON() => Modifier.toJSON(this)

    static fromJSON(map) {
        return Modifier(
            map["name"],
            map["priority"],
            map["target"],
            map.Has("alternates") ? map["alternates"] : false,
            map.Has("else") ? map["else"] : false,
            map.Has("lone_action") ? map["lone_action"] : false,
            map.Has("down_action") ? map["down_action"] : false,
            map.Has("up_action") ? map["up_action"] : false
        )
    }
}

; holds a composition of virtual modifiers
class ModifierComposition extends Composition {

	; --- VARIABLES ---

    ;constructed Significant;
    changed_for_sig := true

    Priority() {
        return Modifier.Priority
    }
    Blank() {
        return KeyProfile.DEFAULT_NAME
    }

	; --- FUNCTIONS ---

    ValidateKeystr(mod) {
        Modifier.CheckValidModifier(mod)
    }

	Add(mod) {
        super.Add(mod)
        this.changed_for_sig := true
	}

	Remove(mod) {
        super.Remove(mod)
        this.changed_for_sig := true
	}

    Clear() {
        super.Clear()
        this.changed_for_sig := true
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

    GetSignificantString() {
        if this.changed_for_sig {
            lowest := false
            for mod in this.List {
                if (
                    (lowest == false) ; lowest not set
                    || (Modifier.RelPriorityOf(mod) < Modifier.RelPriorityOf(lowest)) ; new lowest
                ) {
                    lowest := mod
                }
            }
            this.changed_for_sig := false
            this.Significant := lowest
            return lowest
        }
        return this.Significant
    }

	GetNameString(is_up) {
        ; add up if needed
        return (
            super.GetNameString()
            (is_up ? Modifier.UP_KEYNAME : "")
        )
	}

    GetSyntacticalString() {
        syntactical_modifiers := ""
        for (modifier_name in this.List) {
            mod := ModifierComposition.ModifierOf(modifier_name)

            ; search for symbol from modifier
            symbol := false
            if (mod.else != false) {
                symbol := mod.else
            } else {
                if (Modifier.SYMBOL_SYNTAX_MAP.Has(mod.symbol)) {
                    symbol := Modifier.SYMBOL_SYNTAX_MAP[mod.symbol]
                }
            }
            
            ; add symbol to modifiers if it was found
            if (symbol != false) {
                syntactical_modifiers := syntactical_modifiers symbol
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
                Modifier.List[modifier_name].symbol 
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
}