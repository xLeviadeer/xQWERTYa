#Requires AutoHotkey v2.0
#Include Key.ahk

#Include ../../config/keybinds/-.ahk
#Include ../../config/keybinds/,.ahk
#Include ../../config/keybinds/;.ahk
#Include ../../config/keybinds/..ahk
#Include ../../config/keybinds/'.ahk
#Include ../../config/keybinds/[.ahk
#Include ../../config/keybinds/].ahk
#Include ../../config/keybinds/`.ahk
#Include ../../config/keybinds/=.ahk
#Include ../../config/keybinds/Numbers.ahk
#Include ../../config/keybinds/Backslash.ahk
#Include ../../config/keybinds/BackSpace.ahk
#Include ../../config/keybinds/Delete.ahk
#Include ../../config/keybinds/Enter.ahk
#Include ../../config/keybinds/Escape.ahk
#Include ../../config/keybinds/Insert.ahk
#Include ../../config/keybinds/PgDn.ahk
#Include ../../config/keybinds/PgUp.ahk
#Include ../../config/keybinds/PrintScreen.ahk
#Include ../../config/keybinds/Slash.ahk
#Include ../../config/keybinds/Space.ahk
#Include ../../config/keybinds/Tab.ahk
#Include ../../config/keybinds/Directions.ahk
#Include ../../config/keybinds/MouseKeys.ahk
#Include ../../config/keybinds/NumLock.ahk
#Include ../../config/keybinds/Numpad.ahk
#Include ../../config/keybinds/Functions.ahk
#Include ../../config/keybinds/AppsKey.ahk
#Include ../../config/keybinds/Home.ahk
#Include ../../config/keybinds/Pause.ahk
#Include ../../config/keybinds/End.ahk
#Include ../../config/keybinds/ScrollLock.ahk
#Include ../../config/keybinds/VirtualKeys.ahk
#Include ../../config/keybinds/a.ahk
#Include ../../config/keybinds/b.ahk
#Include ../../config/keybinds/c.ahk
#Include ../../config/keybinds/d.ahk
#Include ../../config/keybinds/e.ahk
#Include ../../config/keybinds/f.ahk
#Include ../../config/keybinds/g.ahk
#Include ../../config/keybinds/h.ahk
#Include ../../config/keybinds/i.ahk
#Include ../../config/keybinds/j.ahk
#Include ../../config/keybinds/k.ahk
#Include ../../config/keybinds/l.ahk
#Include ../../config/keybinds/m.ahk
#Include ../../config/keybinds/n.ahk
#Include ../../config/keybinds/o.ahk
#Include ../../config/keybinds/p.ahk
#Include ../../config/keybinds/q.ahk
#Include ../../config/keybinds/r.ahk
#Include ../../config/keybinds/s.ahk
#Include ../../config/keybinds/t.ahk
#Include ../../config/keybinds/u.ahk
#Include ../../config/keybinds/v.ahk
#Include ../../config/keybinds/w.ahk
#Include ../../config/keybinds/x.ahk
#Include ../../config/keybinds/y.ahk
#Include ../../config/keybinds/z.ahk

; initializes all custom keys
;   needs to be updated with initializations as keys are added
class CustomKeys {
    ; --- VARIABLES ---

    static List := Map()

    ; this list is the one expected to be updated
    static _customKeys => [
        Hyphen,
        Comma,
        Semicolon,
        Period,
        Apostrophe,
        SquareBracketOpen,
        SquareBracketClose,
        Backtick,
        Equals,
        Numbers,
        BackSlash, 
        BackSpace, 
        Delete,
        Enter,
        Escape, 
        Insert,
        PgDn,
        PgUp,
        PrintScreen, 
        Slash,
        Space, 
        Tab,
        Directions,
        MouseKeys, 
        NumLock, 
        Numpad,
        Functions,
        AppsKey,
        Home,
        Pause,
        End,
        ScrollLock, 
        VirtualKeys, 
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        j,
        k,
        l,
        m,
        n,
        o,
        p,
        q,
        r,
        s,
        t,
        u,
        v,
        w,
        x,
        y,
        z
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