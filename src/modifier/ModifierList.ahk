#Requires AutoHotkey v2.0

#Include ../tools/List.ahk

class ModifierList extends List {
    ; --- SERIALIZABLE ---

    static toJSON(obj) => obj.data
    toJSON() => ModifierList.toJSON(this)

    static fromJSON(map_) {
        ; the json will be a list of maps by default; it must be converted to a list of modifier trackers
        
    }
}