#Include ../tools/Composition.ahk
#Include ../modifier/Modifier.ahk
#Include ../modifier/ModifierComposition.ahk
#Include ../lock/Lock.ahk
#Include ../lock/LockComposition.ahk
#Include Key.ahk

class KeyCache {
    ; --- VARIABLES ---

    static DoCaching := false
    
    static ProfCache := Map()
    static CacheOf := false

    ; --- METHODS ---

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

    static SetProfileCache(profile_id) {
        ; wipe current cache if different
        if (
            (KeyCache.CacheOf != false) 
            && (KeyCache.CacheOf == profile_id) 
        ) {
            return ; skip if already set
        }

        ; loop keys
        new_cache := Map()
        for target, ky in Key.List {
            ; default modifier
            KeyCache._AddMod(
                target,
                profile_id,
                KeyProfile.DEFAULT_NAME,
                &new_cache
            )

            ; loop modifiers
            for mod_name, mod in Modifier.List {
                KeyCache._AddMod(
                    target,
                    profile_id,
                    mod_name,
                    &new_cache
                )
            }
        }

        ; set new cache
        KeyCache.CacheOf := profile_id
        KeyCache.ProfCache := new_cache
    }

    static _AddMod(
        target,
        profile_id,
        mod_name,
        &new_cache
    ) {
        ; default lock
        KeyCache._AddLock(
            target,
            profile_id,
            mod_name,
            KeyModifier.DEFAULT_NAME,
            &new_cache
        )

        ; loop locks
        for lock_name, lck in Lock.List {
            ; skip if non-bindable
            if !lck.IsBindable {
                continue
            }

            KeyCache._AddLock(
                target,
                profile_id,
                mod_name,
                lock_name,
                &new_cache
            )
        }
    }

    static _AddLock(
        target,
        profile_id,
        mod_name,
        lock_name,
        &new_cache
    ) {
        ; loop is up
        for is_up in [true, false] {
            cache_key := KeyCache.CreateKey(
                target,
                profile_id,
                mod_name,
                lock_name,
                is_up
            )
            mod_comp := (
                mod_name != KeyProfile.DEFAULT_NAME
                ? ModifierComposition().fromString(mod_name)
                : ModifierComposition()
            ) 
            lck_comp := (
                lock_name != KeyModifier.DEFAULT_NAME
                ? LockComposition().fromString(lock_name)
                : LockComposition()
            )
            new_cache[cache_key] := KeyAction(
                target,
                profile_id,
                mod_comp,
                lck_comp,
                is_up
            ).Resolve()
        }
    }
}
