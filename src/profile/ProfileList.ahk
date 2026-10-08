#Requires AutoHotkey v2.0 

#Include ../tools/List.ahk

class ProfileList extends List {
    ; --- SERIALIZABLE ---

    static toJSON(obj) => obj.data
    toJSON() => ProfileList.toJSON(this)

    static fromJSON(arr) {
        ; the json will be a map of maps by default; it must be converted to a map of profiles
        mapOfProfiles := Map()
        for value in arr {
            prof := Profile.fromJSON(value)
            mapOfProfiles[prof.id] := prof
        }
        return ProfileList(mapOfProfiles)
    }
}