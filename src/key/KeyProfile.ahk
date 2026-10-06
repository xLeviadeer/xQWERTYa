#Include ../modifier/Modifier.ahk

class KeyProfile {

    ; --- VARIABLES ---

    ; -- Static --
    
    static USES_NAME => "uses"
    static USES_PROFILE_NAME => "uses_profile"
    static INHERITS_FROM_NAME => "inherits_from"
    static ELSE_NAME => "else"
    static COLLAPSE_NAME => "collapse"
    static BASED_NAME => "based"
    static DEFAULT_NAME => "default"

    static DEFAULT_UP_NAME => KeyProfile.DEFAULT_NAME Modifier.UP_KEYNAME
    static SHIFT_UP_NAME => Modifier.SHIFT_NAME Modifier.UP_KEYNAME
    static CURL_UP_NAME => Modifier.CURL_NAME Modifier.UP_KEYNAME
    static ALT_UP_NAME => Modifier.ALT_NAME Modifier.UP_KEYNAME
    static CONTROL_UP_NAME => Modifier.CONTROL_NAME Modifier.UP_KEYNAME
    static SHELVE_UP_NAME => Modifier.SHELVE_NAME Modifier.UP_KEYNAME
    static ELEVATE_UP_NAME => Modifier.ELEVATE_NAME Modifier.UP_KEYNAME
    static STEP_UP_NAME => Modifier.STEP_NAME Modifier.UP_KEYNAME
    static WINDOWS_UP_NAME => Modifier.WINDOWS_NAME Modifier.UP_KEYNAME

    static ARROWLOCK_NAME => "arrowlock"
    static ARROWLOCK_UP_NAME => KeyProfile.ARROWLOCK_NAME Modifier.UP_KEYNAME
    static ARROWLOCK_SHIFT_NAME => KeyProfile.ARROWLOCK_NAME Modifier.MODIFIER_JOIN Modifier.SHIFT_NAME
    static ARROWLOCK_SHIFT_UP_NAME => KeyProfile.ARROWLOCK_SHIFT_NAME Modifier.UP_KEYNAME
    static ARROWLOCK_SHIFT_CONTROL_NAME => KeyProfile.ARROWLOCK_SHIFT_NAME Modifier.MODIFIER_JOIN Modifier.CONTROL_NAME
    static ARROWLOCK_SHIFT_CONTROL_UP_NAME => KeyProfile.ARROWLOCK_SHIFT_CONTROL_NAME Modifier.UP_KEYNAME
    static ARROWLOCK_ELEVATE_NAME => KeyProfile.ARROWLOCK_NAME Modifier.MODIFIER_JOIN Modifier.ELEVATE_NAME
    static ARROWLOCK_ELEVATE_UP_NAME => KeyProfile.ARROWLOCK_ELEVATE_NAME Modifier.UP_KEYNAME
    static ARROWLOCK_CONTROL_NAME => KeyProfile.ARROWLOCK_NAME Modifier.MODIFIER_JOIN Modifier.CONTROL_NAME
    static ARROWLOCK_CONTROL_UP_NAME => KeyProfile.ARROWLOCK_CONTROL_NAME Modifier.UP_KEYNAME
    static ARROWLOCK_WINDOWS_NAME => KeyProfile.ARROWLOCK_NAME Modifier.MODIFIER_JOIN Modifier.WINDOWS_NAME
    static ARROWLOCK_WINDOWS_UP_NAME => KeyProfile.ARROWLOCK_WINDOWS_NAME Modifier.UP_KEYNAME

    static CAPSLOCK_NAME => "capslock"
    static CAPSLOCK_UP_NAME => KeyProfile.CAPSLOCK_NAME Modifier.UP_KEYNAME
    static NUMLOCK_NAME => "numlock"
    static NUMLOCK_UP_NAME => KeyProfile.NUMLOCK_NAME Modifier.UP_KEYNAME
    static MOUSE_NAME => "mouselock"
    static MOUSE_UP_NAME => KeyProfile.MOUSE_NAME Modifier.UP_KEYNAME

    static SHIFT_CONTROL_NAME => Modifier.SHIFT_NAME Modifier.MODIFIER_JOIN Modifier.CONTROL_NAME
    static SHIFT_CONTROL_NAME_UP => KeyProfile.SHIFT_CONTROL_NAME Modifier.UP_KEYNAME
    static SHIFT_CURL_NAME => Modifier.SHIFT_NAME Modifier.MODIFIER_JOIN Modifier.CURL_NAME
    static SHIFT_CURL_NAME_UP => KeyProfile.SHIFT_CURL_NAME Modifier.UP_KEYNAME
    static SHIFT_ALT_NAME => Modifier.SHIFT_NAME Modifier.MODIFIER_JOIN Modifier.ALT_NAME
    static SHIFT_ALT_NAME_UP => KeyProfile.SHIFT_ALT_NAME Modifier.UP_KEYNAME
    static SHIFT_ELEVATE_NAME => Modifier.SHIFT_NAME Modifier.MODIFIER_JOIN Modifier.ELEVATE_NAME
    static SHIFT_ELEVATE_NAME_UP => KeyProfile.SHIFT_ELEVATE_NAME Modifier.UP_KEYNAME
    static SHIFT_SHELVE_NAME => Modifier.SHIFT_NAME Modifier.MODIFIER_JOIN Modifier.SHELVE_NAME
    static SHIFT_SHELVE_NAME_UP => KeyProfile.SHIFT_SHELVE_NAME Modifier.UP_KEYNAME
    static SHIFT_STEP_NAME => Modifier.SHIFT_NAME Modifier.MODIFIER_JOIN Modifier.STEP_NAME
    static SHIFT_STEP_NAME_UP => KeyProfile.SHIFT_STEP_NAME Modifier.UP_KEYNAME

    static ALT_ELEVATE_NAME => Modifier.ALT_NAME Modifier.MODIFIER_JOIN Modifier.ELEVATE_NAME
    static ALT_ELEVATE_NAME_UP => KeyProfile.ALT_ELEVATE_NAME Modifier.UP_KEYNAME
    static SHIFT_ALT_ELEVATE_NAME => Modifier.SHIFT_NAME Modifier.MODIFIER_JOIN KeyProfile.ALT_ELEVATE_NAME
    static SHIFT_ALT_ELEVATE_NAME_UP => KeyProfile.SHIFT_ALT_ELEVATE_NAME Modifier.UP_KEYNAME

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

    ;constructed default;
        ;constructed default_up;
    ;constructed shift;
        ;constructed shift_up;
    ;constructed curl;
        ;constructed curl_up;
    ;constructed alt;
        ;constructed alt_up;
    ;constructed control;
        ;contrusted control_up;
    ;constructed shelve;
        ;constructed shelve_up;
    ;constructed elevate;
        ;constructed elevate_up;
    ;constructed step;
        ;constructed step_up;
    ;constructed windows;
        ;constructed windows_up;

    ;constructed arrowlock;
        ;constructed arrowlock_up;
    ;constructed arrowlock_shift;
        ;constructed arrowlock_shift_up;
    ;constructed arrowlock_shift_control;
        ;constructed arrowlock_shift_control_up;
    ;constructed arrowow_elevate;
        ;constructed arrowow_elevate_up;
    ;constructed arrowlock_control;
        ;constructed arrowlock_control_up;
    ; constructed arrowlock_windows;
        ; constructed arrowlock_windows_up;

    ;constructed capslock;
        ;constructed capslock_up;
    ;constructed numlock;
        ;constructed numlock_up;
    ;constructed mouselock;
        ;constructed mouselock_up;

    ;constructed shift_control;
        ;constructed shift_control_up;
    ;constructed shift_curl;
        ;constructed shift_curl_up;
    ;constructed shift_alt;
        ;constructed shift_alt_up;
    ;constructed shift_elevate;
        ;constructed shift_elevate_up;
    ; constructed shift_shelve;
        ;constructed shift_shelve_up;
    ;constructed shift_step;
        ;constructed shift_step_up;

    ;constructed alt_elevate;
        ;constructed alt_elevate_up;
    ;constructed shift_alt_elevate;
        ;constructed shift_alt_elevate_up;

    ; --- CONSTRUCTORS ---

    static IsBool(value) => (
        (value == true)
        || (value == false)
    )
    static CheckBool(value) {
        if !(KeyProfile.IsBool(value)) {
            throw TypeError("binding value must be a bool")
        }
    }

    static IsStrBool(value) => (
        (value is String) ; string
        || ( ; or int with value 0
            (value is Integer)
            && KeyProfile.IsBool(value)
        )
    )
    static CheckStrBool(value) {
        if !(KeyProfile.IsStrBool(value)) {
            throw TypeError("binding value must be a string or bool")
        }
    }

    static IsStrBoolFunc(value) => (
        KeyProfile.IsStrBool(value)
        || (
            (value is Func)
            || (value is BoundFunc)
        )
    )
    static CheckStrBoolFunc(value) {
        if !(KeyProfile.IsStrBoolFunc(value)) {
            throw TypeError("binding value must be a string, function, or 0/false: '" value "'")
        }
    }

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

        default := true,
        default_up := true,

        shift := true,
        shift_up := true,

        curl := true,
        curl_up := true,

        alt := true,
        alt_up := true,

        control := true,
        control_up := true,

        shelve := true,
        shelve_up := true,

        elevate := true,
        elevate_up := true,

        step := true,
        step_up := true,

        windows := true,
        windows_up := true,
        
        arrowlock := true,
        arrowlock_up := true,
        arrowlock_shift := true,
        arrowlock_shift_up := true,
        arrowlock_shift_control := true,
        arrowlock_shift_control_up := true,
        arrowlock_elevate := true,
        arrowlock_elevate_up := true,
        arrowlock_control := true,
        arrowlock_control_up := true,
        arrowlock_windows := true,
        arrowlock_windows_up := true,

        capslock := true,
        capslock_up := true,
        numlock := true,
        numlock_up := true,
        mouselock := true,
        mouselock_up := true,

        shift_control := true,
        shift_control_up := true,
        shift_curl := true,
        shift_curl_up := true,
        shift_alt := true,
        shift_alt_up := true,
        shift_elevate := true,
        shift_elevate_up := true,
        shift_shelve := true,
        shift_shelve_up := true,
        shift_step := true,
        shift_step_up := true,

        alt_elevate := true,
        alt_elevate_up := true,
        shift_alt_elevate := true,
        shift_alt_elevate_up := true
    ) {
        ; uses
        KeyProfile.CheckStrBool(uses)
        this.uses := uses
        ; uses profile
        KeyProfile.CheckStrBool(uses_profile)
        this.uses_profile := uses_profile
        ; inherits from
        KeyProfile.CheckStrBool(inherits_from)
        this.inherits_from := inherits_from
        ; else
        KeyProfile.CheckBool(else_)
        this.else := else_
        ; else explicit
        KeyProfile.CheckBool(else_explicit)
        this.else_explicit := else_explicit
        ; collapse
        KeyProfile.CheckBool(collapse)
        this.collapse := collapse
        ; collapse explicit
        KeyProfile.CheckBool(collapse_explicit)
        this.collapse_explicit := collapse_explicit
        ; based
        KeyProfile.CheckBool(based)
        this.based := based
        ; based explicit
        KeyProfile.CheckBool(based_explicit)
        this.based_explicit := based_explicit

        ; default
        KeyProfile.CheckStrBoolFunc(default)
        this.default := default
        ; default up
        KeyProfile.CheckStrBoolFunc(default_up)
        this.default_up := default_up

        ; shift
        KeyProfile.CheckStrBoolFunc(shift)
        this.shift := shift
        ; shift up
        KeyProfile.CheckStrBoolFunc(shift_up)
        this.shift_up := shift_up

        ; curl
        KeyProfile.CheckStrBoolFunc(curl)
        this.curl := curl
        ; curl_up
        KeyProfile.CheckStrBoolFunc(curl_up)
        this.curl_up := curl_up

        ; alt
        KeyProfile.CheckStrBoolFunc(alt)
        this.alt := alt
        ; alt up
        KeyProfile.CheckStrBoolFunc(alt_up)
        this.alt_up := alt_up

        ; control
        KeyProfile.CheckStrBoolFunc(control)
        this.control := control
        ; control up
        KeyProfile.CheckStrBoolFunc(control_up)
        this.control_up := control_up

        ; elevate
        KeyProfile.CheckStrBoolFunc(elevate)
        this.elevate := elevate
        ; elevate up
        KeyProfile.CheckStrBoolFunc(elevate_up)
        this.elevate_up := elevate_up

        ; shelve
        KeyProfile.CheckStrBoolFunc(shelve)
        this.shelve := shelve
        ; shelve up
        KeyProfile.CheckStrBoolFunc(shelve_up)
        this.shelve_up := shelve_up

        ; step
        KeyProfile.CheckStrBoolFunc(step)
        this.step := step
        ; step up
        KeyProfile.CheckStrBoolFunc(step_up)
        this.step_up := step_up

        ; windows
        KeyProfile.CheckStrBoolFunc(windows)
        this.windows := windows
        ; windows up
        KeyProfile.CheckStrBoolFunc(windows_up)
        this.windows_up:= windows_up

        ; arrow lock
        KeyProfile.CheckStrBoolFunc(capslock)
        this.capslock := capslock
        ; arrow lock up
        KeyProfile.CheckStrBoolFunc(capslock_up)
        this.capslock_up := capslock_up
        ; arrowlock_shift
        KeyProfile.CheckStrBoolFunc(arrowlock_shift)
        this.arrowlock_shift := arrowlock_shift
        ; arrowlock_shift_up
        KeyProfile.CheckStrBoolFunc(arrowlock_shift_up)
        this.arrowlock_shift_up := arrowlock_shift_up
        ; arrowlock_shift_control
        KeyProfile.CheckStrBoolFunc(arrowlock_shift_control)
        this.arrowlock_shift_control := arrowlock_shift_control
        ; arrowlock_shift_control_up
        KeyProfile.CheckStrBoolFunc(arrowlock_shift_control_up)
        this.arrowlock_shift_control_up := arrowlock_shift_control_up
        ; arrowlock_elevate
        KeyProfile.CheckStrBoolFunc(arrowlock_elevate)
        this.arrowlock_elevate := arrowlock_elevate
        ; arrowlock_elevate_up
        KeyProfile.CheckStrBoolFunc(arrowlock_elevate_up)
        this.arrowlock_elevate_up := arrowlock_elevate_up
        ; arrowlock_control
        KeyProfile.CheckStrBoolFunc(arrowlock_control)
        this.arrowlock_control := arrowlock_control
        ; arrowlock_control_up
        KeyProfile.CheckStrBoolFunc(arrowlock_control_up)
        this.arrowlock_control_up := arrowlock_control_up
        ; arrowlock_windows
        KeyProfile.CheckStrBoolFunc(arrowlock_windows)
        this.arrowlock_windows := arrowlock_windows
        ; arrowlock_windows_up
        KeyProfile.CheckStrBoolFunc(arrowlock_windows_up)
        this.arrowlock_windows_up := arrowlock_windows_up

        ; caps lock
        KeyProfile.CheckStrBoolFunc(arrowlock)
        this.arrowlock := arrowlock
        ; caps lock up
        KeyProfile.CheckStrBoolFunc(arrowlock_up)
        this.arrowlock_up := arrowlock_up
        ; num lock
        KeyProfile.CheckStrBoolFunc(numlock)
        this.numlock := numlock
        ; num lock up
        KeyProfile.CheckStrBoolFunc(numlock_up)
        this.numlock_up := numlock_up
        ; mouse lock
        KeyProfile.CheckStrBoolFunc(mouselock)
        this.mouselock := mouselock
        ; mouse lock up
        KeyProfile.CheckStrBoolFunc(mouselock_up)
        this.mouselock_up := mouselock_up

        ; shift control
        KeyProfile.CheckStrBoolFunc(shift_control)
        this.shift_control := shift_control
        ; shift control up
        KeyProfile.CheckStrBoolFunc(shift_control_up)
        this.shift_control_up := shift_control_up
        ; shift curl
        KeyProfile.CheckStrBoolFunc(shift_curl)
        this.shift_curl := shift_curl
        ; shift curl up
        KeyProfile.CheckStrBoolFunc(shift_curl_up)
        this.shift_curl_up := shift_curl_up
        ; shift alt 
        KeyProfile.CheckStrBoolFunc(shift_alt)
        this.shift_alt := shift_alt
        ; shift alt up
        KeyProfile.CheckStrBoolFunc(shift_alt_up)
        this.shift_alt_up := shift_alt_up
        ; shift elevate
        KeyProfile.CheckStrBoolFunc(shift_elevate)
        this.shift_elevate := shift_elevate
        ; shift elevate up
        KeyProfile.CheckStrBoolFunc(shift_elevate_up)
        this.shift_elevate_up := shift_elevate_up
        ; shift shelve 
        KeyProfile.CheckStrBoolFunc(shift_shelve)
        this.shift_shelve := shift_shelve
        ; shift shelve up
        KeyProfile.CheckStrBoolFunc(shift_shelve_up)
        this.shift_shelve_up := shift_shelve_up
        ; shift step
        KeyProfile.CheckStrBoolFunc(shift_step)
        this.shift_step := shift_step
        ; shift step up
        KeyProfile.CheckStrBoolFunc(shift_step_up)
        this.shift_step_up := shift_step_up

        ; control curl
        KeyProfile.CheckStrBoolFunc(alt_elevate)
        this.alt_elevate := alt_elevate
        ; control curl up
        KeyProfile.CheckStrBoolFunc(alt_elevate_up)
        this.alt_elevate_up := alt_elevate_up
        ; shift control curl
        KeyProfile.CheckStrBoolFunc(shift_alt_elevate)
        this.shift_alt_elevate := shift_alt_elevate
        ; shift control curl up
        KeyProfile.CheckStrBoolFunc(shift_alt_elevate_up)
        this.shift_alt_elevate_up := shift_alt_elevate_up
    }

    ; --- SERIALIZABLE ---

    static toJSON(obj) => Map(
        KeyProfile.USES_NAME, obj.uses,
        KeyProfile.USES_PROFILE_NAME, obj.uses_profile,
        KeyProfile.INHERITS_FROM_NAME, obj.inherits_from,
        KeyProfile.ELSE_NAME, obj.else,
        KeyProfile.COLLAPSE_NAME, obj.collapse,
        KeyProfile.BASED_NAME, obj.based,

        KeyProfile.DEFAULT_NAME, obj.default,
        KeyProfile.DEFAULT_UP_NAME, obj.default_up,

        Modifier.SHIFT_NAME, obj.shift,
        KeyProfile.SHIFT_UP_NAME, obj.shift_up,

        Modifier.CURL_NAME, obj.curl,
        KeyProfile.CURL_UP_NAME, obj.curl_up,

        Modifier.ALT_NAME, obj.alt,
        KeyProfile.ALT_UP_NAME, obj.alt_up,

        Modifier.CONTROL_NAME, obj.control,
        KeyProfile.CONTROL_UP_NAME, obj.control_up,

        Modifier.SHELVE_NAME, obj.shelve,
        KeyProfile.SHELVE_UP_NAME, obj.shelve_up,

        Modifier.ELEVATE_NAME, obj.elevate,
        KeyProfile.ELEVATE_UP_NAME, obj.elevate_up,

        Modifier.STEP_NAME, obj.step,
        KeyProfile.STEP_UP_NAME, obj.step_up,

        Modifier.WINDOWS_NAME, obj.windows,
        KeyProfile.WINDOWS_UP_NAME, obj.windows_up,

        KeyProfile.ARROWLOCK_NAME, obj.arrowlock,
        KeyProfile.ARROWLOCK_UP_NAME, obj.arrowlock_up,
        KeyProfile.ARROWLOCK_SHIFT_NAME, obj.arrowlock_shift,
        KeyProfile.ARROWLOCK_SHIFT_UP_NAME, obj.arrowlock_shift_up,
        KeyProfile.ARROWLOCK_SHIFT_CONTROL_NAME, obj.arrowlock_shift_control,
        KeyProfile.ARROWLOCK_SHIFT_CONTROL_UP_NAME, obj.arrowlock_shift_control_up,
        KeyProfile.ARROWLOCK_ELEVATE_NAME, obj.arrowlock_elevate,
        KeyProfile.ARROWLOCK_ELEVATE_UP_NAME, obj.arrowlock_elevate_up,
        KeyProfile.ARROWLOCK_CONTROL_NAME, obj.arrowlock_control,
        KeyProfile.ARROWLOCK_CONTROL_UP_NAME, obj.arrowlock_control_up,
        KeyProfile.ARROWLOCK_WINDOWS_NAME, obj.arrowlock_windows,
        KeyProfile.ARROWLOCK_WINDOWS_UP_NAME, obj.arrowlock_windows_up,

        KeyProfile.CAPSLOCK_NAME, obj.capslock,
        KeyProfile.CAPSLOCK_UP_NAME, obj.capslock_up,
        KeyProfile.NUMLOCK_NAME, obj.numlock,
        KeyProfile.NUMLOCK_UP_NAME, obj.numlock_up,
        KeyProfile.MOUSE_NAME, obj.mouselock
        KeyProfile.MOUSE_UP_NAME, obj.mouselock_up,

        KeyProfile.SHIFT_CONTROL_NAME, obj.shift_control,
        KeyProfile.SHIFT_CONTROL_NAME_UP, obj.shift_control_up,
        KeyProfile.SHIFT_CURL_NAME, obj.shift_curl,
        KeyProfile.SHIFT_CURL_NAME_UP, obj.shift_curl_up,
        KeyProfile.SHIFT_ALT_NAME, obj.shift_alt,
        KeyProfile.SHIFT_ALT_NAME_UP, obj.shift_alt_up,
        KeyProfile.SHIFT_ELEVATE_NAME, obj.shift_elevate,
        KeyProfile.SHIFT_ELEVATE_NAME_UP, obj.shift_elevate_up,
        KeyProfile.SHIFT_SHELVE_NAME, obj.shift_shelve,
        KeyProfile.SHIFT_SHELVE_NAME_UP, obj.shift_shelve_up,
        KeyProfile.SHIFT_STEP_NAME, obj.shift_step,
        KeyProfile.SHIFT_STEP_NAME_UP, obj.shift_step_up,

        KeyProfile.ALT_ELEVATE_NAME, obj.alt_elevate,
        KeyProfile.ALT_ELEVATE_NAME_UP, obj.alt_elevate_up,
        KeyProfile.SHIFT_ALT_ELEVATE_NAME, obj.shift_alt_elevate,
        KeyProfile.SHIFT_ALT_ELEVATE_NAME_UP, obj.shift_alt_elevate_up
    )
    toJson() => KeyProfile.toJSON(this)

    static fromJSON(map_) { 
        ; keep track of found count
        foundCount := 0

        ; check for simplified format
        if (map_ is String) {
            return KeyProfile(
                ,,,,,
                true, ; collapse
                ,,,
                map_ ; default
            )
        }

        ; default
        default := true
        if (map_.Has(KeyProfile.DEFAULT_NAME)) {
            default := map_[KeyProfile.DEFAULT_NAME]
            foundCount += 1
        }
        ; default_up
        default_up := true
        if (map_.Has(KeyProfile.DEFAULT_UP_NAME)) {
            default_up := map_[KeyProfile.DEFAULT_UP_NAME]
            foundCount += 1
        }

        ; shift
        shift := true
        if (map_.Has(Modifier.SHIFT_NAME)) {
            shift := map_[Modifier.SHIFT_NAME]
            foundCount += 1
        }
        ; shift up
        shift_up := true
        if (map_.Has(KeyProfile.SHIFT_UP_NAME)) {
            shift_up := map_[KeyProfile.SHIFT_UP_NAME]
            foundCount += 1
        }

        ; curl
        curl := true
        if (map_.Has(Modifier.CURL_NAME)) {
            curl := map_[Modifier.CURL_NAME]
            foundCount += 1
        }
        ; curl up
        curl_up := true
        if (map_.Has(KeyProfile.CURL_UP_NAME)) {
            curl_up := map_[KeyProfile.CURL_UP_NAME]
            foundCount += 1
        }

        ; alt
        alt := true
        if (map_.Has(Modifier.ALT_NAME)) {
            alt := map_[Modifier.ALT_NAME]
            foundCount += 1
        }
        ; alt_up
        alt_up := true
        if (map_.Has(KeyProfile.ALT_UP_NAME)) {
            alt_up := map_[KeyProfile.ALT_UP_NAME]
            foundCount += 1
        }

        ; control
        control := true
        if (map_.Has(Modifier.CONTROL_NAME)) {
            control := map_[Modifier.CONTROL_NAME]
            foundCount += 1
        }
        ; control_up
        control_up := true
        if (map_.Has(KeyProfile.CONTROL_UP_NAME)) {
            control_up := map_[KeyProfile.CONTROL_UP_NAME]
            foundCount += 1
        }

        ; shelve
        shelve := true
        if (map_.Has(Modifier.SHELVE_NAME)) {
            shelve := map_[Modifier.SHELVE_NAME]
            foundCount += 1
        }
        ; shelve_up
        shelve_up := true
        if (map_.Has(KeyProfile.SHELVE_UP_NAME)) {
            shelve_up := map_[KeyProfile.SHELVE_UP_NAME]
            foundCount += 1
        }

        ; step
        step := true
        if (map_.Has(Modifier.STEP_NAME)) {
            step := map_[Modifier.STEP_NAME]
            foundCount += 1
        }
        ; step_up
        step_up := true
        if (map_.Has(KeyProfile.STEP_UP_NAME)) {
            step_up := map_[KeyProfile.STEP_UP_NAME]
            foundCount += 1
        }

        ; elevate
        elevate := true
        if (map_.Has(Modifier.ELEVATE_NAME)) {
            elevate := map_[Modifier.ELEVATE_NAME]
            foundCount += 1
        }
        ; elevate_up
        elevate_up := true
        if (map_.Has(KeyProfile.ELEVATE_UP_NAME)) {
            elevate_up := map_[KeyProfile.ELEVATE_UP_NAME]
            foundCount += 1
        }

        ; windows
        windows := true
        if (map_.Has(Modifier.WINDOWS_NAME)) {
            windows := map_[Modifier.WINDOWS_NAME]
            foundCount += 1
        }
        ; windows_up
        windows_up := true
        if (map_.Has(KeyProfile.WINDOWS_UP_NAME)) {
            windows_up := map_[KeyProfile.WINDOWS_UP_NAME]
            foundCount += 1
        }

        ; arrow lock
        arrowlock := true
        if (map_.Has(KeyProfile.ARROWLOCK_NAME)) {
            arrowlock := map_[KeyProfile.ARROWLOCK_NAME]
            foundCount += 1
        }
        ; arrow lock up
        arrowlock_up := true
        if (map_.Has(KeyProfile.ARROWLOCK_UP_NAME)) {
            arrowlock_up := map_[KeyProfile.ARROWLOCK_UP_NAME]
            foundCount += 1
        }
        ; arrow lock shift
        arrowlock_shift := true
        if (map_.Has(KeyProfile.ARROWLOCK_SHIFT_NAME)) {
            arrowlock_shift := map_[KeyProfile.ARROWLOCK_SHIFT_NAME]
            foundCount += 1
        }
        ; arrow lock shift up
        arrowlock_shift_up := true
        if (map_.Has(KeyProfile.ARROWLOCK_SHIFT_UP_NAME)) {
            arrowlock_shift_up := map_[KeyProfile.ARROWLOCK_SHIFT_UP_NAME]
            foundCount += 1
        }
        ; arrow lock shift control
        arrowlock_shift_control := true
        if (map_.Has(KeyProfile.ARROWLOCK_SHIFT_CONTROL_NAME)) {
            arrowlock_shift_control := map_[KeyProfile.ARROWLOCK_SHIFT_CONTROL_NAME]
            foundCount += 1
        }
        ; arrow lock shift control up
        arrowlock_shift_control_up := true
        if (map_.Has(KeyProfile.ARROWLOCK_SHIFT_CONTROL_UP_NAME)) {
            arrowlock_shift_control_up := map_[KeyProfile.ARROWLOCK_SHIFT_CONTROL_UP_NAME]
            foundCount += 1
        }
        ; arrow lock elevate
        arrowlock_elevate := true
        if (map_.Has(KeyProfile.ARROWLOCK_ELEVATE_NAME)) {
            arrowlock_elevate := map_[KeyProfile.ARROWLOCK_ELEVATE_NAME]
            foundCount += 1
        }
        ; arrow lock elevate up
        arrowlock_elevate_up := true
        if (map_.Has(KeyProfile.ARROWLOCK_ELEVATE_UP_NAME)) {
            arrowlock_elevate_up := map_[KeyProfile.ARROWLOCK_ELEVATE_UP_NAME]
            foundCount += 1
        }
        ; arrow lock control
        arrowlock_control := true
        if (map_.Has(KeyProfile.ARROWLOCK_CONTROL_NAME)) {
            arrowlock_control := map_[KeyProfile.ARROWLOCK_CONTROL_NAME]
            foundCount += 1
        }
        ; arrow lock control up
        arrowlock_control_up := true
        if (map_.Has(KeyProfile.ARROWLOCK_CONTROL_UP_NAME)) {
            arrowlock_control_up := map_[KeyProfile.ARROWLOCK_CONTROL_UP_NAME]
            foundCount += 1
        }
        ; arrow lock windows
        arrowlock_windows := true
        if (map_.Has(KeyProfile.ARROWLOCK_WINDOWS_NAME)) {
            arrowlock_windows := map_[KeyProfile.ARROWLOCK_WINDOWS_NAME]
            foundCount += 1
        }
        ; arrow lock windows up
        arrowlock_windows_up := true
        if (map_.Has(KeyProfile.ARROWLOCK_WINDOWS_UP_NAME)) {
            arrowlock_windows_up := map_[KeyProfile.ARROWLOCK_WINDOWS_UP_NAME]
            foundCount += 1
        }

        ; caps lock
        capslock := true
        if (map_.Has(KeyProfile.CAPSLOCK_NAME)) {
            capslock := map_[KeyProfile.CAPSLOCK_NAME]
            foundCount += 1
        }
        ; caps lock up
        capslock_up := true
        if (map_.Has(KeyProfile.CAPSLOCK_UP_NAME)) {
            capslock_up := map_[KeyProfile.CAPSLOCK_UP_NAME]
            foundCount += 1
        }
        ; num lock
        numlock := true
        if (map_.Has(KeyProfile.NUMLOCK_NAME)) {
            numlock := map_[KeyProfile.NUMLOCK_NAME]
            foundCount += 1
        }
        ; num lock up
        numlock_up := true
        if (map_.Has(KeyProfile.NUMLOCK_UP_NAME)) {
            numlock_up := map_[KeyProfile.NUMLOCK_UP_NAME]
            foundCount += 1
        }
        ; mouse lock
        mouselock := true
        if (map_.Has(KeyProfile.MOUSE_NAME)) {
            mouselock := map_[KeyProfile.MOUSE_NAME]
            foundCount += 1
        }
        ; mouse lock up
        mouselock_up := true
        if (map_.Has(KeyProfile.MOUSE_UP_NAME)) {
            mouselock_up := map_[KeyProfile.MOUSE_UP_NAME]
            foundCount += 1
        }

        ; shift control
        shift_control := true
        if (map_.Has(KeyProfile.SHIFT_CONTROL_NAME)) {
            shift_control := map_[KeyProfile.SHIFT_CONTROL_NAME]
            foundCount += 1
        }
        ; shift control up
        shift_control_up := true
        if (map_.Has(KeyProfile.SHIFT_CONTROL_NAME_UP)) {
            shift_control_up := map_[KeyProfile.SHIFT_CONTROL_NAME_UP]
            foundCount += 1
        }
        ; shift curl
        shift_curl := true
        if (map_.Has(KeyProfile.SHIFT_CURL_NAME)) {
            shift_curl := map_[KeyProfile.SHIFT_CURL_NAME]
            foundCount += 1
        }
        ; shift curl up
        shift_curl_up := true
        if (map_.Has(KeyProfile.SHIFT_CURL_NAME_UP)) {
            shift_curl_up := map_[KeyProfile.SHIFT_CURL_NAME_UP]
            foundCount += 1
        }
        ; shift alt
        shift_alt := true
        if (map_.Has(KeyProfile.SHIFT_ALT_NAME)) {
            shift_alt := map_[KeyProfile.SHIFT_ALT_NAME]
            foundCount += 1
        }
        ; shift alt up
        shift_alt_up := true
        if (map_.Has(KeyProfile.SHIFT_ALT_NAME_UP)) {
            shift_alt_up := map_[KeyProfile.SHIFT_ALT_NAME_UP]
            foundCount += 1
        }
        ; shift elevate
        shift_elevate := true
        if (map_.Has(KeyProfile.SHIFT_ELEVATE_NAME)) {
            shift_elevate := map_[KeyProfile.SHIFT_ELEVATE_NAME]
            foundCount += 1
        }
        ; shift elevate up
        shift_elevate_up := true
        if (map_.Has(KeyProfile.SHIFT_ELEVATE_NAME_UP)) {
            shift_elevate_up := map_[KeyProfile.SHIFT_ELEVATE_NAME_UP]
            foundCount += 1
        }
        ; shift shelve
        shift_shelve := true
        if (map_.Has(KeyProfile.SHIFT_SHELVE_NAME)) {
            shift_shelve := map_[KeyProfile.SHIFT_SHELVE_NAME]
            foundCount += 1
        }
        ; shift shelve up
        shift_shelve_up := true
        if (map_.Has(KeyProfile.SHIFT_SHELVE_NAME_UP)) {
            shift_shelve_up := map_[KeyProfile.SHIFT_SHELVE_NAME_UP]
            foundCount += 1
        }
        ; shift step
        shift_step := true
        if (map_.Has(KeyProfile.SHIFT_STEP_NAME)) {
            shift_step := map_[KeyProfile.SHIFT_STEP_NAME]
            foundCount += 1
        }
        ; shift step up
        shift_step_up := true
        if (map_.Has(KeyProfile.SHIFT_STEP_NAME_UP)) {
            shift_step_up := map_[KeyProfile.SHIFT_STEP_NAME_UP]
            foundCount += 1
        }

        ; alt elevate
        alt_elevate := true
        if (map_.Has(KeyProfile.ALT_ELEVATE_NAME)) {
            alt_elevate := map_[KeyProfile.ALT_ELEVATE_NAME]
            foundCount += 1
        }
        ; alt elevate up
        alt_elevate_up := true
        if (map_.Has(KeyProfile.ALT_ELEVATE_NAME_UP)) {
            alt_elevate_up := map_[KeyProfile.ALT_ELEVATE_NAME_UP]
            foundCount += 1
        }
        ; shift alt elevate
        shift_alt_elevate := true
        if (map_.Has(KeyProfile.SHIFT_ALT_ELEVATE_NAME)) {
            shift_alt_elevate := map_[KeyProfile.SHIFT_ALT_ELEVATE_NAME]
            foundCount += 1
        }
        ; shift alt elevate up
        shift_alt_elevate_up := true
        if (map_.Has(KeyProfile.SHIFT_ALT_ELEVATE_NAME_UP)) {
            shift_alt_elevate_up := map_[KeyProfile.SHIFT_ALT_ELEVATE_NAME_UP]
            foundCount += 1
        }

        ; uses
        uses := true
        if (map_.Has(KeyProfile.USES_NAME)) {
            uses := map_[KeyProfile.USES_NAME]
            foundCount += 1
        }
        ; uses profile
        uses_profile := true
        if (map_.Has(KeyProfile.USES_PROFILE_NAME)) {
            uses_profile := map_[KeyProfile.USES_PROFILE_NAME]
            foundCount += 1
        }
        ; inherits from 
        inherits_from := true
        if (map_.Has(KeyProfile.INHERITS_FROM_NAME)) {
            inherits_from := map_[KeyProfile.INHERITS_FROM_NAME]
            foundCount += 1
        }
        ; else
        else_explicit := false
        else_ := false
        if (map_.Has(KeyProfile.ELSE_NAME)) {
            else_explicit := true
            else_ := map_[KeyProfile.ELSE_NAME]
            foundCount += 1
        }
        ; collapse
        collapse_explicit := false
        collapse := false
        if (map_.Has(KeyProfile.COLLAPSE_NAME)) {
            collapse_explicit := true
            collapse := map_[KeyProfile.COLLAPSE_NAME]
            foundCount += 1
        }
        ; based
        based_explicit := false
        based := false
        if (map_.Has(KeyProfile.BASED_NAME)) {
            based_explicit := true
            based := map_[KeyProfile.BASED_NAME]
            foundCount += 1
        }

        ; check any keys which were not accounted for that aren't layers
        remaining := (map_.Count - foundCount)
        if (remaining > 0) {
            throw ValueError("key contained an unknown binding key")
        }

        ; return
        return KeyProfile(
            uses,
            uses_profile,
            inherits_from,
            else_,
            else_explicit,
            collapse,
            collapse_explicit,
            based,
            based_explicit,

            default,
            default_up,

            shift,
            shift_up,

            curl,
            curl_up,

            alt,
            alt_up,

            control,
            control_up,

            shelve,
            shelve_up,

            elevate,
            elevate_up,
            
            step,
            step_up,

            windows,
            windows_up,

            arrowlock,
            arrowlock_up,
            arrowlock_shift,
            arrowlock_shift_up,
            arrowlock_shift_control,
            arrowlock_shift_control_up,
            arrowlock_elevate,
            arrowlock_elevate_up,
            arrowlock_control,
            arrowlock_control_up,
            arrowlock_windows,
            arrowlock_windows_up,

            capslock,
            capslock_up,
            numlock,
            numlock_up,
            mouselock,
            mouselock_up,

            shift_control,
            shift_control_up,
            shift_curl,
            shift_curl_up,
            shift_alt,
            shift_alt_up,
            shift_elevate,
            shift_elevate_up,
            shift_shelve,
            shift_shelve_up,
            shift_step,
            shift_step_up,

            alt_elevate,
            alt_elevate_up,
            shift_alt_elevate,
            shift_alt_elevate_up
        )
    }
}