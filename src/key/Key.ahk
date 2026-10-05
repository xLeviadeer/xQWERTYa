#Requires AutoHotkey v2.0 
#Include ../tools/List.ahk
#Include KeyProfile.ahk
#Include CustomKeys.ahk
#Include ../profile/Profile.ahk
#Include ../tools/JSON.ahk
#Include ../Locks.ahk
#Include ../modifier/Modifier.ahk
#Include ../key/KeyAction.ahk
#Include ../tools/Utils.ahk

; testing based include
doDump := false
#Include ../../lib/JSONBase.ahk

; code for binding keys and holding their data
class Key {
    
    ; --- VARIABLES ---

    ;constructed target;
    ;constructed unsafe;
    ;constructed strict;
    ;constructed profiles;

    ; -- Static --

    ; path
    static KEYBINDS_PATH => "config/keybinds"

    ; special characters
    static MOUSE_PREFIX => "="
    static ACTION_PREFIX => "@"
    static DOWN_PREFIX => "_"
    static PROFILE_PREFIX => ">"
    static LOCK_PREFIX => "<"

    ; letter keys
    static LetterKeys := Utils.SetOf(
        "a","b","c","d","e","f","g","h","i","j","k","l","m",
        "n","o","p","q","r","s","t","u","v","w","x","y","z",
        " ","1","2","3","4","5","6","7","8","9","0"
    )
    static letterPressTime => 5000
    static letterPressRequirement => 5
    static addLetterPress() => Key.letterPressCount += 1
    static subLetterPress() => Key.letterPressCount -= 1
    static resetLetterPress() => Key.letterPressCount := 0
    static letterPressCount := 0
    static IsLetterKey(key_name) => Key.LetterKeys.Has(key_name)

    ; key registry
    static List := List()

    ; used combinations map
    static UsedCombinations := Map()

    ; down key lazy init tracker
    static DownTracking := Map()

    ; bool to text helper
    static BoolToText => Map(
        true, "On",
        false, "Off"
    )

    ; --- CONSTRUCIOR ---

    static Create(
        target,
        unsafe,
        strict,
        profiles
    ) {
        ; create new
        cls := Key(target, unsafe, strict, profiles)

        ; set to map
        Key.List[cls.target] := cls
    }

    __New(
        target,
        unsafe,
        strict,
        profiles
    ) {
        ; check target
        if !(target is String) {
            throw TypeError("target must be a string")
        }
        if (Key.List.Has(target)) {
            throw ValueError("target already exists in the Key.List; a key cannot be targetted for binding twice")
        }
        this.target := target

        ; check unsafe
        if (
            (unsafe != true)
            && (unsafe != false)
        ) {
            throw TypeError("unsafe must be a boolean")
        }
        this.unsafe := unsafe

        ; check strict
        if (
            (strict != true)
            && (strict != false)
        ) {
            throw ValueError("strict must be a boolean")
        }
        this.strict := strict

        ; check profiles
        if !(profiles is Map) {
            throw TypeError("profiles must be a map")
        }
        this.profiles := Map()
        for key_, value in profiles {
            if !(key_ is String) {
                throw TypeError("profile key be a string")
            }
            if !(value is KeyProfile) {
                throw TypeError("KeyProfiles in Key must be a map of string: KeyProfile")  
            } 
            this.profiles[key_] := value
        }
    }

    ; --- INIT ---

    static init() {
        ; loop through all files in the keybinds directory
        loop files Key.KEYBINDS_PATH "/*.json" {          
            ; read file contents
            keyObj := JSON.LoadFile(Key, (Key.KEYBINDS_PATH "/" A_LoopFileName), "UTF-8")
            Key.List[keyObj.target] := keyObj
        }
    }

    ; --- SERIALIZABLE ---

    static toJSON(obj) => Map(
        "target", obj.target,
        "unsafe", obj.unsafe,
        "strict", obj.strict,
        "profiles", obj.profiles
    )
    toJSON() => Key.toJSON(this)

    static fromJSON(map_) {
        ; the json will be a map of maps by default; it must be converted to a map of KeyProfiles
        mapOfKeyProfiles := Map()
        foundDefault := false
        foundAtLeastOneProfile := false
        foundTarget := false
        foundUnsafe := false
        foundStrict := false
        for key_, value in map_ {
            foundAtLeastOneProfile := true

            ; skip target
            if (key_ == "target") {
                foundTarget := true
                continue
            }

            ; skip unsafe
            if (key_ == "unsafe") {
                foundUnsafe := true
                continue
            }

            ; skip strict
            if (key_ == "strict") {
                foundStrict := true
                continue
            }

            ; look for default
            if (key_ == Profile.DEFAULT_NAME) {
                foundDefault := true
            } else if !(Profile.List.Has(key_)) { ; check profile is a profile in the profiles list
                throw ValueError("'" key_ "' is not a profile in profiles.json")
            }

            ; add
            mapOfKeyProfiles[key_] := KeyProfile.fromJSON(value)
        }

        ; if no target
        if !(foundTarget) {
            throw ValueError("a key must have a target")
        }

        ; if no profiles
        if !(foundAtLeastOneProfile) {
            throw ValueError("a key must contain at least one profile")
        }

        ; error if no default
        if (foundDefault == false) {
            throw ValueError("keys must have a default profile; bind '" map_["target"] "' has no default bind")
        }

        ; return new key
        return Key(
            map_["target"],
            (foundUnsafe ? map_["unsafe"] : false),
            (foundStrict ? map_["strict"] : false),
            mapOfKeyProfiles
        )
    } 

    ; --- ENABLE/DISABLE KEYS ---

    ; sets a combination to enabled or disabled
    static _SetKey(combination, enabled) {
        Hotkey(combination, , Key.BoolToText[enabled])
    }

    ; enabled expects an enabled bool, true to enable, false to disable
    ; key_names_list expects a list of validated key target strings ╎ if ⦅left blank⦆/⦅set to false⦆ then acts on all combinations
    ; list_is_exceptions expects a bool determining if the key_names_list should be taken as a set of keys to ⊰not⊱ act on instead of a list of keys ⊰to⊱ act on
    ; set_all_keys expects a bool determining whether to set keys which are either 𝓇᚜ part of the exceptions ᚛᚜ not part of the list ᚛ depending on exception mode
    static SetKeys(enabled, key_names_list := false, list_is_exceptions := false, set_all_keys := false) {
        ; no key names list check
        if (key_names_list == false) {
            ; set all to enabled/disabled
            for (key_name, combination in Key.UsedCombinations) {
                Key._SetKey(combination, enabled)
            }
            return
        }

        ; extend list with up keys
        key_names_list_extension := []
        for (key_name in key_names_list) {
            key_name_up := key_name Modifier.UP_KEYNAME
            if (Key.UsedCombinations.Has(key_name_up)) {
                key_names_list_extension.Push(key_name_up)
            }
        }
        key_names_list.Push(key_names_list_extension*)
        
        ; generate map from list
        key_names_set := Map()
        for (key_name in key_names_list) {
            key_names_set[key_name] := false
        }
        
        ; loop over all combinations
        for (key_name, combination in Key.UsedCombinations) {
            ; if list is exceptions, check if curr is exception
            if (list_is_exceptions) {
                if !(key_names_set.Has(key_name)) { ; if not exception, set
                    Key._SetKey(combination, enabled)
                } else if (set_all_keys) { ; if set all keys, set opposite 
                    Key._SetKey(combination, !enabled)
                } ; no set keys & in list, do nothing
            } else { ; not exceptions
                if (key_names_set.Has(key_name)) { ; if in list, set
                    Key._SetKey(combination, enabled)
                } else if (set_all_keys) { ; if set all keys, set opposite
                    Key._SetKey(combination, !enabled)
                } ; no set keys & not in list, do nothing
            }
        }
    }

    ; --- BIND ---

    static _BindWithName(name) {
        ; bind with name
        try {
            Hotkey(
                name,
                (ThisHotkey) => KeyAction.HandleKey(ThisHotkey)
            )
        } catch ValueError { ; catch invalid targets
            throw ValueError("'" name "' is not a real key; it is an invalid target which is not a real key")
        }
    }

    ; binds all keys in the list
    static BindAll() {
        ; for every key in the keylist
        for key_target, key_ in Key.List {
            ; create binding name
            bindingName := (
                (key_.strict ? "" : Modifier.ALL_PREFIX)
                (key_.unsafe ? "" : Modifier.SAFTEY_PREFIX)
                key_target
            )
            bindingNameUp := bindingName Modifier.UP_KEYSYMBOL_LONG

            ; bind down and up
            Key._BindWithName(bindingName)
            Key.UsedCombinations[key_target] := bindingName
            if !(key_.strict) { ; no up bind on strict keys
                Key._BindWithName(bindingNameUp)
                Key.UsedCombinations[key_target Modifier.UP_KEYNAME] := bindingNameUp
            }
        }

        ; DEBUG
        global doDump
        if (doDump) {
            JSONBase.DumpFile(Key.UsedCombinations, "./test/dump.json", true)
            MsgBox("created dump")
        }
    }
}