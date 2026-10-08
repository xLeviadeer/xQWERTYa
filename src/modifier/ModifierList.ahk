#Requires AutoHotkey v2.0

#Include ../tools/List.ahk
#Include Modifier.ahk

class ModifierList extends List {
    ; --- SERIALIZABLE ---

    static toJSON(obj) => obj.data
    toJSON() => ModifierList.toJSON(this)

    static fromJSON(arr) {
        ; the json will be a list of maps by default; it must be converted to a list of modifier trackers
        map_of_modifiers := Map()
        for value in arr {
            mod := Modifier.fromJSON(value)
            map_of_modifiers[mod.name] := mod
        }
        return ModifierList(map_of_modifiers)
    }
}