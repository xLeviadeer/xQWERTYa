#Requires AutoHotkey v2.0

class Utils {
    static SetOf(values*) {
        set := Map()
        for (val in values) {
            set[val] := true
        }
        return set
    }

    static Clamp(num, _min, _max) => Min(Max(num, _min), _max)
}