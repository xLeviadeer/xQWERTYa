#Requires AutoHotkey v2.0 

#Include ..\Profile\Profile.ahk
#Include ..\key\key.ahk
#Include ..\key\CustomKeys.ahk
#Include ..\modifier\Modifier.ahk
#Include ..\lock\Lock.ahk
#Include ..\tools\Badge.ahk
#Include ..\key\KeyCache.ahk

class Launcher {
    ; --- VARIABLES ---

    static LAUNCH_SETTINGS_PATH => "config/launch.json"

    ; --- CONSTRUCTOR ---

    __New(
        cache_size,
        max_hotkeys_per_interval,
        process_priority,
        do_admin
    ) {
        if (
            !(cache_size is Integer)
            || (cache_size < 0)
        ) {
            throw TypeError("cach_size must be a positive integer")
        }
        this.cache_size := cache_size

        if (
            !(max_hotkeys_per_interval is Integer)
            || (max_hotkeys_per_interval <= 0)
        ) {
            throw TypeError("max_hotkeys_per_interval must be a positive non-zero integer")
        }
        this.max_hotkeys_per_interval := max_hotkeys_per_interval

        if !(process_priority is String) {
            throw TypeError("process_priority must be a string")
        }
        this.process_priority := process_priority

        Checks.CheckBool(do_admin)
        this.do_admin := do_admin
    }

    ; --- METHODS ---

    static launch(
        cache_size := unset, ; unset as read
        max_hotkeys_per_interval := unset, ; unset as read
        process_priority := unset, ; unset as read
        do_admin := unset ; unset as read
    ) {
        ; default settings read
        if ( ; if any false
            !IsSet(cache_size)
            || !IsSet(max_hotkeys_per_interval)
            || !IsSet(process_priority)
            || !IsSet(do_admin)
        ) {
            if (
                !FileExist(Launcher.LAUNCH_SETTINGS_PATH)
                || (FileGetSize(Launcher.LAUNCH_SETTINGS_PATH) == 0)
            ) {
                throw Error(Launcher.LAUNCH_SETTINGS_PATH " does not exist or is empty | all data must be provided or " Launcher.LAUNCH_SETTINGS_PATH " must exist with all data that is not provided")
            }
            settings := JSON.LoadFile(Launcher, Launcher.LAUNCH_SETTINGS_PATH, "UTF-8")

            ; set missing only
            if !IsSet(cache_size) {
                cache_size := settings.cache_size
            }
            if !IsSet(max_hotkeys_per_interval) {
                max_hotkeys_per_interval := settings.max_hotkeys_per_interval
            }
            if !IsSet(process_priority) {
                process_priority := settings.process_priority
            }
            if !IsSet(do_admin) {
                do_admin := settings.do_admin
            }
        }

        ; admin check
        if do_admin {
            ; copied and updated for v2 from: https://www.autohotkey.com/docs/v1/lib/Run.htm#RunAs
            full_command_line := DllCall("GetCommandLine", "str")
            if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
                try {
                    if A_IsCompiled
                        Run("*RunAs `"" A_ScriptFullPath "`" /restart")
                    else
                        Run("*RunAs " A_AhkPath " /restart `"" A_ScriptFullPath "`"")
                }
                ExitApp()
            }
        }

        ; toplevel settings
        ProcessSetPriority(process_priority)
        A_MaxHotkeysPerInterval := max_hotkeys_per_interval

        ; disable caps lock as it'll be being enumlated anyway
        SetCapsLockState("AlwaysOff")
        A_StoreCapsLockMode := false
        SetNumLockState("AlwaysOn")

        BADGE_BUILD_BG := "3d3c49"
        BADGE_BUILD_FG := "625f8a"
        BADGE_START_BG := "5b5a6e"
        BADGE_START_FG := "9d99db"
        BADGE_LOC := "Middle"

        ; init badge
        Badge.init()

        ; init locks
        Badge.ShowBadge(
            "building locks",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        Lock.init()

        ; init modifiers
        Badge.ShowBadge(
            "building modifiers",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        Modifier.init()

        ; init profiles
        Badge.ShowBadge(
            "building profiles",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        Profile.init()

        ; init keys
        Badge.ShowBadge(
            "building keys",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        Key.init()

        ; init custom keys
        Badge.ShowBadge(
            "building custom keys",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        CustomKeys.init()

        ; create profile cache
        Badge.ShowBadge(
            "pooling cache",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        KeyCache.init(cache_size)

        ; init signifiers
        Badge.ShowBadge(
            "formatting signifiers",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        ActionSignifier.init()

        ; bind modifiers
        Badge.ShowBadge(
            "binding modifiers",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        Modifier.BindAll()

        ; bind keys
        Badge.ShowBadge(
            "binding keys",
            BADGE_LOC,
            BADGE_BUILD_BG,
            BADGE_BUILD_FG
        )
        Key.BindAll()

        ; startup badge
        Badge.ShowBadge(
            "Started",
            BADGE_LOC,
            BADGE_START_BG,
            BADGE_START_FG
        )
    }

    ; --- SERIALIZABLE ---

    static toJSON(launcher) => Map(
        "cache_size", launcher.cach_size,
        "max_hotkeys_per_interval", launcher.max_hotkeys_per_interval,
        "process_priority", launcher.process_priority,
        "admin", launcher.do_admin
    )
    toJSON() => Launcher.toJSON(this)

    static fromJSON(map) {
        return Launcher(
            map["cache_size"],
            map["max_hotkeys_per_interval"],
            map["process_priority"],
            map["admin"]
        )
    }
}
