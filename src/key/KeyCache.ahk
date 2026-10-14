#Include ../tools/Composition.ahk
#Include ../modifier/Modifier.ahk
#Include ../modifier/ModifierComposition.ahk
#Include ../lock/Lock.ahk
#Include ../lock/LockComposition.ahk
#Include Key.ahk
#Include ../tools/RollingBuffer.ahk

class KeyCache {

    ; --- VARIABLES ---

    static DoCaching := false

    static RECENT_CACHE_SIZE => 300
    static RecentCache := unset

    ; --- INIT ---

    static init() {
        ; set up recent cache
        KeyCache.RecentCache := RollingBuffer(KeyCache.RECENT_CACHE_SIZE)
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
