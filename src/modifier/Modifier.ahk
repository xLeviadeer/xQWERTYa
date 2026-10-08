#include ../Key/Key.ahk
#Include ../key/KeyProfile.ahk
#Include ../Profile/Profile.ahk
#Include ../tools/List.ahk
#Include ../tools/JSON.ahk
#Include ModifierComposition.ahk
#Include ModifierList.ahk
#Include ../../config/modifiers/ModifierActions.ahk

; tracks and manages the state of virtual modifiers
class Modifier {

    ; --- VARIABLES ---

    ; -- static --

    static MODIFIERS_PATH => "config/modifiers/modifiers.json"

    ; - prefixes -

    static PASSTHROUGH_SYMBOL => "~"
    static ALL_PREFIX => "*"
    static SAFTEY_PREFIX => "$"

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
        Modifier.SHIFT_SYNTAX,
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
        ; check if modifiers.json exists & priority
        if (FileExist(Modifier.MODIFIERS_PATH)) {
            try {
                Modifier.List := JSON.LoadFile(ModifierList, Modifier.MODIFIERS_PATH, "UTF-8")
            } catch (Error) {
            }
        }
        Modifier.Priority := Utils.OrderByPriority(Modifier.List)

        ; symbol to name & used symbols
        Modifier.SymbolToName := Map("", KeyProfile.DEFAULT_NAME)
        Modifier.UsedSymbols := Map()
        for name, value in Modifier.List {
            ; symbol to name
            Modifier.SymbolToName[value.symbol] := name

            ; duplicates
            if Modifier.UsedSymbols.Has(value.symbol) {
                throw ValueError("cannot use target ⸉" value.symbol "⸉ because it has already been used")
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
            if !ModifierActions.HasProp(this.lone_action_name) {
                throw ValueError("Actions does not contain a method named ⸉" this.lone_action_name "⸉")
            }
            return () => ModifierActions.%this.lone_action_name%()
        }
    }
    down_action {
        get {
            if (this.down_action_name == false) {
                return false
            }
            if !ModifierActions.HasProp(this.down_action_name) {
                throw ValueError("Actions does not contain a method named ⸉" this.down_action_name "⸉")
            }
            return () => ModifierActions.%this.down_action_name%()
        }
    }
    up_action {
        get {
            if (this.up_action_name == false) {
                return false
            }
            if !ModifierActions.HasProp(this.up_action_name) {
                throw ValueError("Actions does not contain a method named ⸉" this.up_action_name "⸉")
            }
            return () => ModifierActions.%this.up_action_name%()
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
        for name, value in Modifier.List {
            ; check if the modifier is on
            if value.isDown {
                comp.Add(name)
            }
        }
        return comp
    }

    ; --- VALIDATION ---

    ; checks if a string is a valid modifier
    static CheckValidModifier(str) {
		if !(
			(str is String)
			&& (Modifier.List.Has(str))
		) {
			throw ValueError("⸉" str "⸉ is not a valid modifier name")
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