#Requires AutoHotkey v2.0

class Utils {
    static BoolToText => Map(
        true, "On",
        false, "Off"
    )
    
    static SetOf(values*) {
        set := Map()
        for (val in values) {
            set[val] := true
        }
        return set
    }

    static Clamp(num, _min, _max) => Min(Max(num, _min), _max)

    static IndexOf(arr, ele) {
        i := 1
        for search_ele in arr {
            if search_ele == ele {
                return i
            }
            i += 1
        }
        throw ValueError("ele " ele " is not in the provided list")
    }

    ; expects 
    ;   list — List
    static OrderByPriority(list) {
        priority := Array()
        for name, value in list {
            ; priority
            if (priority.Length == 0) {
                priority.Push(name)
            } else {
                ; adds in increasing priority order not allowing duplicates
                i := 1
                added := false
                for search_name in priority {
                    search_priority := list[search_name].priority
                    if (value.priority == search_priority) {
                        throw ValueError("error creating priority: two priorities cannot have the same value: " search_priority " on " name)
                    }
                    if (search_priority > value.priority) {
                        priority.InsertAt(i, name)
                        added := true
                        break
                    }
                    ; incr
                    i += 1
                }
                if (added == false) {
                    priority.Push(name)
                }
            }
        }
        return priority
    }
}