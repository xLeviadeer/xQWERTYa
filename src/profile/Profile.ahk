#Requires AutoHotkey v2.0 
#Include ProfileList.ahk
#Include ../Key/Key.ahk
#Include ../tools/JSON.ahk
#Include ../tools/Badge.ahk
#Include ../Key/Modifier.ahk

class Profile {
    
    ; --- VARIABLES ---

    ; -- Static --

    ; will store a profile by an id
    static List := ProfileList()
    static ListVisible := ProfileList()
    static PROFILES_PATH => "config/profiles.json"

    ; current profile tracker
    static DEFAULT_NAME => "default"
    static DEFAULT_MODIFIER_PASSTHROUGH => Map(
        "shift", true,
        "control", true,
        "curl", false,
        "alt", false,
        "elevate", false,
        "shelve", false,
        "step", false,
        "windows", false
    )
    static DEFAULT_EXCEPTIONS => false
    static DEFAULT_COMPATIBILITY => true
    static DEFAULT_BASED => true
    static DEFAULT_COLLAPSE => true
    static DEFAULT_ELSE => false
    static DEFAULT_BLIND => false 
    static DEFAULT_QUICK_SWITCH => false
    static Curr := Profile.DEFAULT_NAME

    ; returns a profile object or false if the default profile
    static GetCurr() {
        if (Profile.Curr == Profile.DEFAULT_NAME) {
            return false
        }
        return Profile.List[Profile.Curr]
    }

    ; -- Instance --

    ;constructed id;
    ;constructed name;
    ;constructed inheritsFrom?;
    ;constructed modifierPassthrough?;
    ;constructed exceptions;
    ;constructed hidden?;
    ;constructed compatibility?;
    ;constructed based?;
    ;constructed collapse?;
    ;constructed else?;
    ;constructed blind?;
    ;constructed color?;
    ;constructed showBadge?;
    ;constructed disablesLetters?;
    ;constructed quickSwitch?;

    ; --- CONSTRUCTORS ---

    ; creates new profile, adding it to the list
    static Create(
        id,
        name,
        inheritsFrom := Profile.DEFAULT_NAME,
        modifierPassthrough := false,
        exceptions := false,
        hidden := false,
        compatibility := false,
        based := false,
        collapse := false,
        else_ := false,
        blind := true,
        color := Badge.COLOR_FOREGROUND,
        showBadge := true,
        disablesLetters := false,
        quickSwitch := false
    ) {
        ; create new
        cls := Profile(
            id, 
            name, 
            inheritsFrom, 
            modifierPassthrough, 
            exceptions,
            hidden, 
            compatibility, 
            based,
            collapse,
            else_,
            blind,
            color, 
            showBadge, 
            disablesLetters,
            quickSwitch
        )

        ; set to map
        Profile.List[cls.id] := cls
    }

    ; real constructor
    __New(
        id,
        name,
        inheritsFrom := Profile.DEFAULT_NAME,
        modifierPassthrough := false,
        exceptions := false,
        hidden := false,
        compatibility := false,
        based := false,
        collapse := false,
        else_ := false,
        blind := true,
        color := Badge.COLOR_FOREGROUND,
        showBadge := true,
        disablesLetters := false,
        quickSwitch := false
    ) {
        ; check id
        if !(id is String) {
            throw TypeError("id must be a string")
        }
        if (Profile.List.Has(id)) {
            throw ValueError("id already exists and cannot be defined twice")
        }
        this.id := id

        ; check name
        if !(name is String) {
            throw TypeError("name must be a string")
        }
        this.name := name

        ; check inheritsFrom
        if !(inheritsFrom is String) {
            throw TypeError("inheritsFrom must be a string")
        }
        this.inheritsFrom := inheritsFrom

        ; check modifier passthroughs
        if (modifierPassthrough != false) {
            if (!(modifierPassthrough is Map)) {
                throw TypeError("modifierPassthrough must be false or a map of string modifier key names and boolean values")
            }
            for key_, value in modifierPassthrough {
                ; check key
                if (
                    !(key_ is String)
                    && !(ModifierTracker.List.Has(key_))
                ) {
                    throw ValueError("'" key_ "' is not a valid modifier name")
                }

                ; check value
                if (
                    (value != true)
                    && (value != false)
                ) {
                    throw ValueError("'" value "' value must be a boolean")
                }
            }
        }
        this.modifierPassthrough := modifierPassthrough

        ; check exceptions
        if (exceptions != false) {
            if (!(exceptions is Array)) {
                throw TypeError("exceptions must be false or an array of string key names")
            }
            for (key_ in exceptions) {
                ; check string
                if !(key_ is String) {
                    throw TypeError("exceptions must be string key names")
                }
            }
        }
        this.exceptions := exceptions

        ; check hidden
        if (
            (hidden != true)
            && (hidden != false)
        ) {
            throw TypeError("hidden must be a boolean")
        }
        this.hidden := hidden

        if (
            (compatibility != true)
            && (compatibility != false)
        ) {
            throw TypeError("compatibility must be a boolean")
        }
        this.compatibility := compatibility

        ; check based
        if (
            (based != true)
            && (based != false)
        ) {
            throw TypeError("based must be a boolean")
        }
        this.based := based

        ; check collapsed
        if (
            (collapse != true)
            && (collapse != false)
        ) {
            throw TypeError("collapsed must be a boolean")
        }
        this.collapse := collapse

        ; check elsed
        if (
            (else_ != true)
            && (else_ != false)
        ) {
            throw TypeError("elsed must be a boolean")
        }
        this.else := else_

        ; check blind
        if (
            (blind != true)
            && (blind != false)
        ) {
            throw TypeError("blind must be a boolean")
        }
        this.blind := blind

        ; check color
        if !(color is String) {
            throw TypeError("color must be a string")
        }
        this.color := color

        ; check showBadge
        if (
            (showBadge != true)
            && (showBadge != false)
        ) {
            throw TypeError("showBadge must be a boolean")
        }
        this.showBadge := showBadge

        ; check disablesLetters
        if (
            (disablesLetters != true)
            && (disablesLetters != false)
        ) {
            throw TypeError("disablesLetters must be a boolean")
        }
        this.disablesLetters := disablesLetters

        ; quick switch
        if (
            (quickSwitch != true)
            && (quickSwitch != false)
        ) {
            throw TypeError("quickSwitch must be a boolean")
        }
        this.quickSwitch := quickSwitch
    }

    ; --- DATA ---

    is_or_inherits(profile_id) {
        if (profile_id == Profile.DEFAULT_NAME) {
            return true ; all profiles inherit from default
        } else {
            if !Profile.List.Has(profile_id) { ; error not a valid profile id
                throw ValueError("profile_id is not a valid profile id: " profile_id)
            }
            if profile_id == this.id { ; true if profile matches this id
                return True
            }
            inherits_from := Profile.List[this.id].inheritsFrom
            if inherits_from == Profile.DEFAULT_NAME { ; if inherits_from is default (and profile_id is not default) then false
                return False
            } 
            return Profile.List[inherits_from].is_or_inherits(profile_id) ; recurse to the inherited profile
        }
    }

    ; --- INIT ---

    static init() {
        ; check if profiles.json exists
        relative_path := Profile.PROFILES_PATH
        if (FileExist(relative_path)) {
            ; set list
            Profile.List := JSON.LoadFile(ProfileList, relative_path, "UTF-8")
        }

        ; set list of only visible profiles
        for key_, value in Profile.List {
            if (value.hidden) { 
                continue 
            }
            Profile.ListVisible[key_] := value
        }

        ; turn on compatibility mode if on
        Profile._SetCompatibility(Profile.DEFAULT_NAME)
    }

    ; --- SERIALIZABLE ---

    static toJSON(profile) => Map(
        "id", profile.id,
        "name", profile.name,
        "modifierPassthrough", profile.modifierPassthrough,
        "exceptions", profile.exceptions,
        "inheritsFrom", profile.inheritsFrom,
        "hidden", profile.hidden,
        "compatibility", profile.compatibility,
        KeyProfile.BASED_NAME, profile.based,
        KeyProfile.COLLAPSE_NAME, profile.collapse,
        KeyProfile.ELSE_NAME, profile.else,
        "blind", profile.blind,
        "color", profile.color,
        "showBadge", profile.showBadge,
        "disablesLetters", profile.disablesLetters,
        "quickSwitch", profile.quickSwitch
    )
    toJSON() => Profile.toJSON(this)
    
    static fromJSON(map) {
        return Profile(
            map["id"],
            map["name"],
            map.Has("inheritsFrom") ? map["inheritsFrom"] : Profile.DEFAULT_NAME,
            map.Has("modifierPassthrough") ? map["modifierPassthrough"] : false,
            map.Has("exceptions") ? map["exceptions"] : false,
            map.Has("hidden") ? map["hidden"] : false,
            map.Has("compatibility") ? map["compatibility"] : false,
            map.Has(KeyProfile.BASED_NAME) ? map[KeyProfile.BASED_NAME] : false,
            map.Has(KeyProfile.COLLAPSE_NAME) ? map[KeyProfile.COLLAPSE_NAME] : false,
            map.Has(KeyProfile.ELSE_NAME) ? map[KeyProfile.ELSE_NAME] : false,
            map.Has("blind") ? map["blind"] : true,
            map.Has("color") ? map["color"] : Badge.COLOR_FOREGROUND,
            map.Has("showBadge") ? map["showBadge"] : true,
            map.Has("disablesLetters") ? map["disablesLetters"] : false,
            map.Has("quickSwitch") ? map["quickSwitch"] : false
        )
    }

    ; --- SWITCHING ---

    ; delay requirement
    static ACTIVATION_DELAY => 100 ; 10 cps max
    static isDelaying := false
    static RunDelay() {
        Profile.isDelaying := true
        SetTimer(() => Profile.isDelaying := false, -Profile.ACTIVATION_DELAY)
    }

    _ShowChange(show_badge := -1 ) {
        ; skip for show_badge settings
        if (show_badge == -1) { ; unset
            if !(this.showBadge) { ; check profile settings
                return
            }
        } else if (show_badge == false) { ; explicit no
            return
        }

        ; show badge
        Badge.ShowBadge(this.name, , , this.color)
    }

    static GetPassthrough(profile_id) {
        ; get the pass list
        if (profile_id == Profile.DEFAULT_NAME) {
            return Profile.DEFAULT_MODIFIER_PASSTHROUGH 
        } else {
            if (Profile.List[profile_id].modifierPassthrough == false) {
                return Profile.DEFAULT_MODIFIER_PASSTHROUGH 
            } else {
                return  Profile.List[profile_id].modifierPassthrough
            }
        }
    }

    static _SetPassthrough(profile_id) {
        ; get passthrough list
        pass_list := Profile.GetPassthrough(profile_id)

        ; for all passthrough values
        for (pass_modifier_name, pass_do_passthrough in pass_list) {
            ModifierTracker.UpdatePassthrough(pass_modifier_name, pass_do_passthrough)
        }
    }

    static _SetCompatibility(profile_id) {
        if (profile_id == Profile.DEFAULT_NAME) {
            Locks.Setcompatibility(Profile.DEFAULT_COMPATIBILITY, false)
        } else {
            prof := Profile.GetCurr()
            Locks.Setcompatibility(prof.compatibility, false)
        }
    }

    static _validated_exceptions := Map() ; lazy validates exceptions (set)
    static SetExceptions(profile_id) {
        ; get exceptions list
        if (profile_id == Profile.DEFAULT_NAME) {
            exceptions := Profile.DEFAULT_EXCEPTIONS
        } else {
            exceptions := Profile.GetCurr().exceptions
        }

        ; validate exceptions
        if !(Profile._validated_exceptions.Has(profile_id)) {
            ; auto validate false
            if (exceptions == false) {
                Profile._validated_exceptions[profile_id] := false
            } else {
                ; validate list
                for (exception in exceptions) {
                    if !(Key.List.Has(exception)) {
                        throw ValueError("exception (⸉" exception "⸉) for ⸉" profile_id "⸉ is not a valid key target")
                    }
                }
                Profile._validated_exceptions[profile_id] := false
            }
        }

        ; set all keys to on if false
        if (exceptions == false) {
            Key.SetKeys(true)
            return
        }

        ; set exceptions
            ; sets all exceptions to false
            ; all other keys are explicitly set to true
        Key.SetKeys(false, exceptions, false, true)
    }

    static last_profile_was_quick_switcher := Profile.DEFAULT_QUICK_SWITCH
    static _profile_switch(profile_id) {
        ; switch for default for quick switching
        if (Profile.Curr == Profile.DEFAULT_NAME) {
            Profile.last_profile_was_quick_switcher := Profile.DEFAULT_QUICK_SWITCH
        } else {
            Profile.last_profile_was_quick_switcher := Profile.GetCurr().quickSwitch
        }

        ; update curr
        Profile.Curr := profile_id
    }

    static _do_quick_switch(profile_id) {
        ; true if last was quick switch
        if (Profile.last_profile_was_quick_switcher) {
            return true
        } 

        ; check if default
        if (profile_id == Profile.DEFAULT_NAME) {
            return Profile.DEFAULT_QUICK_SWITCH
        } else {
            return Profile.List[profile_id].quickSwitch
        }
    }
    static _UpdateForProfile(profile_id) {
        ; if quick switch, do nothing
        if !(Profile._do_quick_switch(profile_id)) {
            Profile._SetCompatibility(profile_id)
            Profile._SetPassthrough(profile_id)
            Profile.SetExceptions(profile_id)
            Profile.RunDelay()
        }
    }

    ; switches to a profile of the given string's id
    static SwitchTo(id, show_badge := -1) {
        ; don't activate if delaying
        if (Profile.isDelaying) {
            return
        }

        ; if the default profile
        if (id == Profile.DEFAULT_NAME) {
            Profile._profile_switch(Profile.DEFAULT_NAME)
            if (
                (show_badge == true) ; true
                || (show_badge == -1) ; unset
            ) {
                Badge.ShowBadge(Profile.DEFAULT_NAME, , , Badge.COLOR_FOREGROUND)
            }
            Profile._UpdateForProfile(Profile.DEFAULT_NAME)
            return
        }

        ; check the given id is a profile
        if !(Profile.List.Has(id)) {
            throw ValueError("'" id "' is not a valid profile")
        } 

        ; switch to
        Profile._profile_switch(id)
        Profile.GetCurr()._ShowChange(show_badge)
        Profile._UpdateForProfile(id)
    }

    ; cycles to the next profile in the list
    static Cycle() {
        ; don't activate if delaying
        if (Profile.isDelaying) {
            return
        }

        ; check if there any profiles to cycle
        if (Profile.List.Count == 0) {
            return
        }

        ; get position
        ;   if the profile isn't in the list visible it will be -1
        ;   and hence be turned into the default profile
        position := Profile.ListVisible.IndexOf(Profile.Curr)

        ; if default profile set to first profile
        if (position == -1) { 
            prof := Profile.ListVisible.At(1)
            Profile._profile_switch(prof.id)
            prof._ShowChange()
            Profile._UpdateForProfile(prof.id)
            return
        }
        positionAdjusted := position + 1

        ; if next profile is out of bounds, set to default
        if (positionAdjusted > Profile.ListVisible.Count) {
            Profile._profile_switch(Profile.DEFAULT_NAME)
            Badge.ShowBadge(Profile.DEFAULT_NAME, , , Badge.COLOR_FOREGROUND)
            Profile._UpdateForProfile(Profile.DEFAULT_NAME)
            return
        }

        ; set to next profile
        Profile._profile_switch(Profile.ListVisible.KeyAt(positionAdjusted))
        prof := Profile.ListVisible[Profile.Curr]
        prof._ShowChange()
        Profile._UpdateForProfile(prof.id)
    }
}