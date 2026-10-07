#Requires AutoHotkey v2.0

#Include ../tools/Composition.ahk
#Include Modifier.ahk

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