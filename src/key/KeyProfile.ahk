#Include ../tools/Utils.ahk
#Include ../tools/Checks.ahk
#Include KeyModifier.ahk

class KeyProfile {

    ; --- VARIABLES ---

    ; -- Static --
    
    static _MODIFIERS_NAME => "modifiers"
    static _EXPLICIT_KEYNAME => "_explicit"

    static USES_NAME => "uses"
    static USES_PROFILE_NAME => "uses_profile"
    static INHERITS_FROM_NAME => "inherits_from"
    static ELSE_NAME => "else"
    static _ELSE_EXPLICIT_NAME => KeyProfile.ELSE_NAME KeyProfile._EXPLICIT_KEYNAME 
    static COLLAPSE_NAME => "collapse"
    static _COLLAPSE_EXPLICIT_NAME => KeyProfile.COLLAPSE_NAME KeyProfile._EXPLICIT_KEYNAME 
    static BASED_NAME => "based"
    static _BASED_EXPLICIT_NAME => KeyProfile.BASED_NAME KeyProfile._EXPLICIT_KEYNAME 

    static DEFAULT_NAME => "default"
    static DEFAULT_NAME_UP => KeyProfile.DEFAULT_NAME Modifier.UP_KEYNAME

    ; -- Instance --

    ;constructed uses;
    ;constructed uses_profile;
    ;constructed inherits_from;
    ;constructed else;
        ;constructed else_explicit;
    ;constructed collapse;
        ;constructed collapse_explicit;
    ;constructed based;
        ;constructed based_explicit;
    ;constructed modifiers;

    ; --- GET/SET ---

    __Get(search_name, search_params) {
        ; search own props
        if ObjHasOwnProp(this, search_name) {
            return this.GetOwnPropDesc(search_name).Value
        }

        ; search map
        if this.HasProp(search_name) {
            return this.GetOwnPropDesc(KeyProfile._MODIFIERS_NAME).Value[search_name]
        }
    }

    __Set(search_name, search_params, set_value) {
        ; search map
        if this.HasProp(search_name) {
            this.GetOwnPropDesc(KeyProfile._MODIFIERS_NAME).Value[search_name].Set(set_value)
            return
        }
        this.DefineProp(search_name, {value:set_value})
        return set_value
    }

    HasProp(search_name) {
        ; search own props
        if ObjHasOwnProp(this, search_name) {
            return true
        }
        
        ; search map
        if (
            this.HasOwnProp(KeyProfile._MODIFIERS_NAME)
            && (this.GetOwnPropDesc(KeyProfile._MODIFIERS_NAME).Value != false)
        ) {
            return this.GetOwnPropDesc(KeyProfile._MODIFIERS_NAME).Value.Has(search_name)
        }
        return false
    }

    ; --- CONSTRUCTORS ---

    __New(
        uses := true,
        uses_profile := true,
        inherits_from := true,
        else_ := false,
        else_explicit := false,
        collapse := false,
        collapse_explicit := false,
        based := false,
        based_explicit := false,
        default := false,
        default_up := false,
        modifiers := false
    ) {
        ; uses
        Checks.CheckStrBool(uses)
        this.uses := uses
        ; uses profile
        Checks.CheckStrBool(uses_profile)
        this.uses_profile := uses_profile
        ; inherits from
        Checks.CheckStrBool(inherits_from)
        this.inherits_from := inherits_from
        ; else
        Checks.CheckBool(else_)
        this.else := else_
        ; else explicit
        Checks.CheckBool(else_explicit)
        this.else_explicit := else_explicit
        ; collapse
        Checks.CheckBool(collapse)
        this.collapse := collapse
        ; collapse explicit
        Checks.CheckBool(collapse_explicit)
        this.collapse_explicit := collapse_explicit
        ; based
        Checks.CheckBool(based)
        this.based := based
        ; based explicit
        Checks.CheckBool(based_explicit)
        this.based_explicit := based_explicit

        ; default
        Checks.CheckStrBoolFunc(default)
        this.default := default
        ; default up
        Checks.CheckStrBoolFunc(default_up)
        this.default_up := default_up

        ; modifiers
        if (modifiers != false) {
            if !(modifiers is Map) {
                throw TypeError("modifiers must be a map of modifier names and associated actions")
            }
            for name, value in modifiers {
                ; if it can be composed from a string we know it's valid even if we don't need it now
                ModifierComposition().fromString(name)
                ; value must be KeyModifier or bool
                if (
                    !(Checks.IsBool(value))
                    && !(value is KeyModifier)
                ) {
                    throw TypeError("value (of " name ") must be an instance of KeyModifier or a boolean")
                }
            }
        }
        this.modifiers := modifiers
    }

    ; --- SERIALIZABLE ---

    static toJSON(kprof) {
        map_ := Map(
            KeyProfile.USES_NAME, kprof.uses,
            KeyProfile.USES_PROFILE_NAME, kprof.uses_profile,
            KeyProfile.INHERITS_FROM_NAME, kprof.inherits_from,
            KeyProfile.ELSE_NAME, kprof.else,
            KeyProfile.COLLAPSE_NAME, kprof.collapse,
            KeyProfile.BASED_NAME, kprof.based,
            KeyProfile.DEFAULT_NAME, kprof.default,
            KeyProfile.DEFAULT_NAME_UP, kprof.default_up
        )
        if kprof.modifiers != false {
            for name, value in kprof.modifiers {
                map_[name] := value
            }
        }
        return map_
    }
    toJson() => KeyProfile.toJSON(this)

    static _JSON_EXCLUDES => Utils.SetOf(
        KeyProfile.USES_NAME,
        KeyProfile.USES_PROFILE_NAME,
        KeyProfile.INHERITS_FROM_NAME,
        KeyProfile.ELSE_NAME,
        KeyProfile._ELSE_EXPLICIT_NAME,
        KeyProfile.COLLAPSE_NAME,
        KeyProfile._COLLAPSE_EXPLICIT_NAME,
        KeyProfile.BASED_NAME,
        KeyProfile._BASED_EXPLICIT_NAME,
        KeyProfile.DEFAULT_NAME,
        KeyProfile.DEFAULT_NAME_UP
    )
    static fromJSON(data) { 
        ; check for simplified format
        if (data is String) {
            return KeyProfile(
                ,,,,,
                true, ; collapse
                ,,,
                data ; default
            )
        }

        data_excess := Map()
        for name, value in data {
            if KeyProfile._JSON_EXCLUDES.Has(name) {
                continue
            }

            ; check for semi-simplified format
            if value is String {
                data_excess[name] := KeyModifier(value)
                continue
            } 

            ; create from json data
            if value is Map {
                data_excess[name] := KeyModifier.fromJSON(value)
                continue
            }

            ; false (unset)
            if Checks.IsBool(value) {
                data_excess[name] := value
                continue
            }

            throw TypeError("KeyProfile modifier value must be a String, KeyModifier or a boolean")
        }
        return KeyProfile(
            data.Has(KeyProfile.USES_NAME) ? data[KeyProfile.USES_NAME] : true,
            data.Has(KeyProfile.USES_PROFILE_NAME) ? data[KeyProfile.USES_PROFILE_NAME] : true,
            data.Has(KeyProfile.INHERITS_FROM_NAME) ? data[KeyProfile.INHERITS_FROM_NAME] : true,
            data.Has(KeyProfile.ELSE_NAME) ? data[KeyProfile.ELSE_NAME] : false,
            data.Has(KeyProfile._ELSE_EXPLICIT_NAME) ? data[KeyProfile._ELSE_EXPLICIT_NAME] : false,
            data.Has(KeyProfile.COLLAPSE_NAME) ? data[KeyProfile.COLLAPSE_NAME] : false,
            data.Has(KeyProfile._COLLAPSE_EXPLICIT_NAME) ? data[KeyProfile._COLLAPSE_EXPLICIT_NAME] : false,
            data.Has(KeyProfile.BASED_NAME) ? data[KeyProfile.BASED_NAME] : false,
            data.Has(KeyProfile._BASED_EXPLICIT_NAME) ? data[KeyProfile._BASED_EXPLICIT_NAME] : false,
            data.Has(KeyProfile.DEFAULT_NAME) ? data[KeyProfile.DEFAULT_NAME] : false,
            data.Has(KeyProfile.DEFAULT_NAME_UP) ? data[KeyProfile.DEFAULT_NAME_UP] : false,
            data_excess
        )
    }
}