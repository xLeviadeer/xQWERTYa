#Requires AutoHotkey v2.0

#Include ../modifier/Modifier.ahk

; class that describes a key event
class KeyEvent {

    ; --- VARIABLES ---

    ;constructed key_target;
    ;constructed is_up;

    ; --- CONSTRUCTOR ---

    __New(
        key_target,
        is_up
    ) {
        this.key_target := key_target
        this.is_up := is_up
    }

    static FromHotkeyString(HotkeyString) {
        ; match positions out of the hotkey name
        RegExMatch(
            HotkeyString,
            "^(?!.*\+.*\+)(?!.*\$.*\$)[\*\$]+",
            &info
        )
        splitPosition := 0
        if (info is RegExMatchInfo) {
            splitPosition := info.Len
        }

        ; check if it's an up action
        hotkeyStringLen := StrLen(HotkeyString)
        upKeysymbolLen := StrLen(Modifier.UP_KEYSYMBOL_LONG)
        cutLength := 0
        is_up := false
        if (
            (hotkeyStringLen > upKeysymbolLen) ; long enough to contain " Up"
            && (SubStr( ; ends with " Up"
                HotkeyString, 
                hotkeyStringLen - (upKeysymbolLen - 1),
                hotkeyStringLen
            ) == Modifier.UP_KEYSYMBOL_LONG)
        ) {
            cutLength := upKeysymbolLen
            is_up := true
        }

        ; get the key name out of the hotkey name
        key_target := SubStr(
            HotkeyString,
            splitPosition + 1,
            (hotkeyStringLen - (splitPosition - 1)) - (cutLength + 1)
        )

        ; return new
        return KeyEvent(key_target, is_up)
    }
}