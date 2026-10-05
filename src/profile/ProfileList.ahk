#Requires AutoHotkey v2.0 

#Include ../tools/List.ahk

class ProfileList extends List {
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