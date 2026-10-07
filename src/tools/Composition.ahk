#Requires AutoHotkey v2.0

; holds a composition of virtual strings
class Composition {

	; --- VARIABLES ---

    ; -- Static --

    static JOIN => "_"

    ; -- Instance --

	;constructed List;
	;constructed Str;
	changed_for_str := true
    Length => this.List.Count
    IsTripleBind => this.List.Count > 1

    ;abstract Priority() -> Array
    Priority() {
        throw MethodError("PriorityRef is not implemented")
    }
    ;abstract Blank() -> String
    Blank() {
        throw MethodError("Blank is not implemented")
    }

    ; --- INDEXABLE ---

    __Item[key] {
        get => this.List[key]
        set => this.List[key] := value
    }

    __Enum(NumberOfVars) => this.List.__Enum(NumberOfVars)

	; --- CONSTRUCTOR ---

	__New(v*) {
        ; set keystr helper
        this.List := Map()

		; parse v
        v_length := 0
        for (_ in v) {
            v_length += 1
        }
		if (v_length >= 1) {
			completed := false
			if (v_length == 2) {
				if (v[1] is Composition) { ; keystr composition copy
					for (keystr, _ in v.List) {
						this.Add(keystr)
					}

					completed := true
				} else if (v[1] is Array) { ; list of values
					for (keystr in v[1]) {
						this.Add(keystr)
					}

					completed := true
				}
			}
			if !(completed) { ; multiple values
				for (keystr in v) {
					this.Add(keystr)
				}
			}
		}
	}

    ; --- VALIDATION ---

    ;abstract static ValidateKeystr(keystr) -> unset ⧙raises error⧘
    ValidateKeystr(keystr) {
        throw MethodError("ValidateKeystr is not implemented")
    }

	; --- FUNCTIONS ---

	Add(keystr) {
        this.ValidateKeystr(keystr)
		this.List[keystr] := false
		this.changed_for_str := true
	}

	Remove(keystr) {
        this.ValidateKeystr(keystr)
		this.List.Remove(keystr)
		this.changed_for_str := true
	}

    Clear() {
        this.List.Clear()
        this.changed_for_str := true
    }

	; --- GET STRINGS ---

	GetNameString() {
		; construct new if needed
		if (this.changed_for_str) {
            ; if values
            composition_str := ""
            if (this.List.Count > 0) {
                isFirstKeystr := true
                for (keystr in this.Priority()) {
                    if (this.List.Has(keystr)) {
                        composition_str := (
                            composition_str 
                            (isFirstKeystr ? "" : Composition.JOIN)
                            keystr
                        )
                        isFirstKeystr := false
                    }
                }
            } else { ; no values
                composition_str := this.Blank()
            }
            this.changed_for_str := false
            this.Str := composition_str
        }
        return this.Str
	}

    ; --- COPY ---

    fromString(str) {
        final_comp := %this.__Class%()
        substrs := StrSplit(str, Composition.JOIN)
        i := 1
        for keystr in this.Priority() {
            substr := substrs[i]
            this.ValidateKeystr(substr)
            if keystr == substr {
                i += 1
                final_comp.Add(substr)
                if i > substrs.Length {
                    break
                } else { 
                    continue 
                }
            }
        }
        if (i - 1) != substrs.Length {
            throw ValueError("provided composition string (" str ") does not follow keystr priority")
        }
        return final_comp
    }

    Copy() {
        return %this.__Class%(this.List*)
    }
}