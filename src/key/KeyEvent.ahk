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
        ; get lengths
        hotkeyStringLen := StrLen(HotkeyString)
        upKeysymbolLen := StrLen(Modifier.UP_KEYSYMBOL_LONG)

        ; match positions out of the hotkey name
        splitPosition := 0
        loop hotkeyStringLen {
            char := SubStr(HotkeyString, splitPosition + 1, 1)
            if (
                (char == "*")
                || (char == "$")
            ) {
                splitPosition += 1
                continue
            }
            break
        }

        ; check if it's an up action
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