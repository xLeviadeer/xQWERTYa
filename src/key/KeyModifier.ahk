#Requires AutoHotkey v2.0

#Include ../tools/Checks.ahk
#Include ../tools/Utils.ahk
#Include ../lock/LockComposition.ahk

; a map holding a modifier's associated no-lock and lock based behavior
    ; does ¡not¡ actually include the modifier itself
class KeyModifier {

    ; --- VARIABLES ---

    static _UNSET => -1

    default := KeyModifier._UNSET
    locks := KeyModifier._UNSET

    ; --- GET/SET ---

    __Get(search_name, search_params) {
        ; search own props
        if ObjHasOwnProp(this, search_name) {
            return this.GetOwnPropDesc(search_name).Value
        }

        ; search map
        if (
            this.HasOwnProp("locks")
            && this.GetOwnPropDesc("locks").Value.Has(search_name)
        ) {
            return this.GetOwnPropDesc("locks").Value[search_name]
        }
    }

    __Set(search_name, search_params, value) {
        ; search map
        if this.HasProp(search_name) {
            this.GetOwnPropDesc("locks").Value[search_name].Set(value)
            return
        }
        this.DefineProp(search_name, {value:search_name})
        return value
    }

    HasProp(search_name) {
        ; search own props
        if ObjHasOwnProp(this, search_name) {
            return true
        }
        
        ; search map
        return (
            this.HasOwnProp("locks")
            && this.GetOwnPropDesc("locks").Value.Has(search_name)
        )
    }

    ; --- CONSTRUCTOR ---

    __New(
        default := false,
        locks := false
    ) {
        Checks.CheckStrBoolFunc(default)
        this.default := default

        if (locks != false) {
            if !(locks is Map) {
                throw TypeError("locks must be a map of lock names and associated actions")
            }
            for lock_name, value in locks {
                ; if it can be composed from a string we know it's valid even if we don't need it now
                LockComposition().fromString(lock_name)
                ; value must be strboolfunc like default
                Checks.CheckStrBoolFunc(value)
            }
        } 
        this.locks := locks
    }

    ; --- SERIALIZABLE ---

    static toJSON(kmod) {
        map_ := Map("default", kmod.default)
        if kmod.locks != false {
            for name, value in kmod.locks {
                map_[name] := value
            }
        }
        return map_
    }
    toJSON() => KeyModifier.toJSON(this)

    static _JSON_EXCLUDES => Utils.SetOf(
        "default"
    )
    static fromJSON(data) {
        data_excess := Map()
        for name, value in data {
            if KeyModifier._JSON_EXCLUDES.Has(name) {
                continue
            }
            data_excess[name] := value
        }
        return KeyModifier(
            data.Has("default") ? data["default"] : false,
            data_excess
        )
    }
}