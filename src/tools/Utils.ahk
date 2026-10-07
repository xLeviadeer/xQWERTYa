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

    static IsBool(value) => (
        (value == true)
        || (value == false)
    )
    static CheckBool(value) {
        if !(Utils.IsBool(value)) {
            throw TypeError( "value (" Type(value) ") must be a boolean")
        }
    }

}