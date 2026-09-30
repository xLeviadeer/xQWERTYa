#Requires AutoHotkey v2.0 
#Include Profile.ahk

class ProfileList {

    ; --- VARIABLES ---

    ;constructed data;

    ; --- INDEXABLE ---

    __Item[key] {
        get => this.data[key]
        set => this.data[key] := value
    }

    __Enum(NumberOfVars) => this.data.__Enum(NumberOfVars)

    Has(key) => this.data.Has(key)
    Keys() {
        keys := Array()
        for key_, value in this.data {
            keys.Push(key_)
        }
        return keys
    }
    IndexOf(key) {
        i := 1
        for key_ in this.Keys() {
            if (key_ == key) {
                return i
            }
            i += 1
        }
        return -1
    }
    KeyAt(position) {
        if (
            (this.data.Count < position)
            || (position <= 0)
        ) {
            throw IndexError("index '" position '" out of bounds')
        }
        return this.Keys()[position]
    }
    At(position) {
        return this.data[this.KeyAt(position)]
    }

    Count => this.data.Count

    ; --- CONSTRUCTORS ----

    __New(v*) {
        if (v.Length == 0) {
            this.data := Map()
        } else if (
            (v.Length == 1)
            && (v[1] is Map)
        ) { ; map value
            this.data := v[1]
        } else { ; key, value values
            this.data := Map()
            for value in v {
                this.data[value.id] := value
            }
        }
    }

    ; --- SERIALIZABLE ---

    static toJSON(obj) => obj.data
    toJSON() => ProfileList.toJSON(this)

    static fromJSON(map_) {
        ; the json will be a map of maps by default; it must be converted to a map of profiles
        mapOfProfiles := Map()
        for key_, value in map_ {
            mapOfProfiles[key_] := Profile.fromJSON(value)
        }
        return ProfileList(mapOfProfiles)
    }
}