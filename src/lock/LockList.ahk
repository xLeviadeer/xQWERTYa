#Requires AutoHotkey v2.0

#Include ../tools/List.ahk
#Include Lock.ahk

class LockList extends List {
    ; --- SERIALIZABLE ---

    static toJSON(obj) => obj.data
    toJSON() => LockList.toJSON(this)

    static fromJSON(arr) {
        ; the json will be a list of maps by default; it must be converted to a list of modifier trackers
        map_of_modifiers := Map()
        for value in arr {
            lck := Lock.fromJSON(value)
            map_of_modifiers[lck.name] := lck
        }
        return LockList(map_of_modifiers)
    }
}