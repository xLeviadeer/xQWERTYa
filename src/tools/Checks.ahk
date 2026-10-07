#Requires AutoHotkey v2.0

class Checks {
    static IsBool(value) => (
        (value == true)
        || (value == false)
    )
    static CheckBool(value) {
        if !(Checks.IsBool(value)) {
            throw TypeError( "value (" Type(value) ") must be a boolean")
        }
    }

    static IsStrBool(value) => (
        (value is String) ; string
        || ( ; or int with value 0
            (value is Integer)
            && Checks.IsBool(value)
        )
    )
    static CheckStrBool(value) {
        if !(Checks.IsStrBool(value)) {
            throw TypeError("binding value must be a string or bool")
        }
    }

    static IsStrBoolFunc(value) => (
        Checks.IsStrBool(value)
        || (
            (value is Func)
            || (value is BoundFunc)
        )
    )
    static CheckStrBoolFunc(value) {
        if !(Checks.IsStrBoolFunc(value)) {
            throw TypeError("binding value must be a string, function, or 0/false: '" value "'")
        }
    }
}