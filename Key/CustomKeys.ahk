#Requires AutoHotkey v2.0
#Include Key.ahk


; initializes all custom keys
;   needs to be updated with initializations as keys are added
class CustomKeys {
    ; --- VARIABLES ---

    static List := Map()

    ; this list is the one expected to be updated
    static _customKeys => [
    ]

    ; --- CONSTRUCTORS ---

    static init() {
        ; init all keys and add to list
        for cls in CustomKeys._customKeys {

            ; check for init method and run
            if (cls.HasMethod("init")) {
                cls.init()
            }

            ; check for target/targets and add
            if (cls.HasProp("target")) {
                CustomKeys.List[cls.target] := cls
            } else if (cls.HasProp("targets")) {
                for target in cls.targets {
                    CustomKeys.List[target] := cls
                }
            }
        }
    }
}