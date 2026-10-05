#Requires AutoHotkey v2.0 

#Include ..\Profile\Profile.ahk
#Include ..\key\key.ahk
#Include ..\key\CustomKeys.ahk
#Include ..\modifier\Modifier.ahk
#Include ..\tools\Badge.ahk

launch() {
    ; spam protection highened window
    A_MaxHotkeysPerInterval := 300

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

; conventions for default include
    ; shift is falsed
    ; alt is falsed
    ; control is elsed
    ; windows is elsed
    ; curl is falsed
    ; elevate is falsed
    ; shelve is falsed

