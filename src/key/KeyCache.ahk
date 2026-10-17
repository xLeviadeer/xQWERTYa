#Include ../tools/Composition.ahk
#Include ../modifier/Modifier.ahk
#Include ../modifier/ModifierComposition.ahk
#Include ../lock/Lock.ahk
#Include ../lock/LockComposition.ahk
#Include Key.ahk
#Include ../tools/RollingBuffer.ahk

class KeyCache {

    ; --- VARIABLES ---

    static RecentCache := unset

    ; --- INIT ---

    static init(cache_size) {
        ; set up recent cache
        if cache_size == 0 {
            KeyCache.RecentCache := false
            return
        }
        KeyCache.RecentCache := RollingBuffer(cache_size)
    }

    ; --- KEYING ---

    static CreateKey(
        target,
        profile_id,
        mod_combo,
        lck_combo,
        is_up
    ) {
        return (
            target 
            Composition.JOIN profile_id
            (mod_combo != "" ? Composition.JOIN mod_combo : "")
            (lck_combo != "" ? Composition.JOIN lck_combo : "")
            (is_up ? Modifier.UP_KEYNAME : "")
        )
    }
}
