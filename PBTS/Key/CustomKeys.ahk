#Requires AutoHotkey v2.0
#Include Key.ahk

#Include ../../keybinds/-.ahk
#Include ../../keybinds/,.ahk
#Include ../../keybinds/;.ahk
#Include ../../keybinds/..ahk
#Include ../../keybinds/'.ahk
#Include ../../keybinds/[.ahk
#Include ../../keybinds/].ahk
#Include ../../keybinds/`.ahk
#Include ../../keybinds/=.ahk
#Include ../../keybinds/Numbers.ahk
#Include ../../keybinds/Backslash.ahk
#Include ../../keybinds/BackSpace.ahk
#Include ../../keybinds/Delete.ahk
#Include ../../keybinds/Enter.ahk
#Include ../../keybinds/Escape.ahk
#Include ../../keybinds/Insert.ahk
#Include ../../keybinds/PgDn.ahk
#Include ../../keybinds/PgUp.ahk
#Include ../../keybinds/PrintScreen.ahk
#Include ../../keybinds/Slash.ahk
#Include ../../keybinds/Space.ahk
#Include ../../keybinds/Tab.ahk
#Include ../../keybinds/Directions.ahk
#Include ../../keybinds/MouseKeys.ahk
#Include ../../keybinds/NumLock.ahk
#Include ../../keybinds/Numpad.ahk
#Include ../../keybinds/Functions.ahk
#Include ../../keybinds/AppsKey.ahk
#Include ../../keybinds/Home.ahk
#Include ../../keybinds/Pause.ahk
#Include ../../keybinds/End.ahk
#Include ../../keybinds/ScrollLock.ahk
#Include ../../keybinds/VirtualKeys.ahk
#Include ../../keybinds/a.ahk
#Include ../../keybinds/b.ahk
#Include ../../keybinds/c.ahk
#Include ../../keybinds/d.ahk
#Include ../../keybinds/e.ahk
#Include ../../keybinds/f.ahk
#Include ../../keybinds/g.ahk
#Include ../../keybinds/h.ahk
#Include ../../keybinds/i.ahk
#Include ../../keybinds/j.ahk
#Include ../../keybinds/k.ahk
#Include ../../keybinds/l.ahk
#Include ../../keybinds/m.ahk
#Include ../../keybinds/n.ahk
#Include ../../keybinds/o.ahk
#Include ../../keybinds/p.ahk
#Include ../../keybinds/q.ahk
#Include ../../keybinds/r.ahk
#Include ../../keybinds/s.ahk
#Include ../../keybinds/t.ahk
#Include ../../keybinds/u.ahk
#Include ../../keybinds/v.ahk
#Include ../../keybinds/w.ahk
#Include ../../keybinds/x.ahk
#Include ../../keybinds/y.ahk
#Include ../../keybinds/z.ahk

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