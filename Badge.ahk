#Requires AutoHotkey v2.0

#Include Timer.ahk

class Badge {

    ; --- VARIABLES ---

    static TOOLTIP_TIME_MS => 2500

    static SCREEN_SCALE => A_ScreenDPI / 96 ; 96 dpi is 100%
    static SCREEN_SCALED_WIDTH => A_ScreenWidth / Badge.SCREEN_SCALE
    static SCREEN_SCALED_HEIGHT => A_ScreenHeight / Badge.SCREEN_SCALE

    static TOOLTIP_WINDOW_WIDTH => 400
    static TOOLTIP_WINDOW_HEIGHT => 100

    static COLOR_BACKGROUND => "A5A5A5"
    static COLOR_FOREGROUND => "000000"

    ; --- CACHE ---

    static position_names := Map(
        "Left", (Badge.SCREEN_SCALED_WIDTH / 20),
        "Middle", (Badge.SCREEN_SCALED_WIDTH / 2) - (Badge.TOOLTIP_WINDOW_WIDTH / 2),
        "Right", (Badge.SCREEN_SCALED_WIDTH - (Badge.SCREEN_SCALED_WIDTH / 20)) - Badge.TOOLTIP_WINDOW_WIDTH
    )
    static badge_cache := Map()
    static text_cache := Map()

    ; --- INIT --- 

    static init() {
        
        ; for left, right, middle
        for (position_name, position_x in Badge.position_names) {
            new_badge := Gui(, "Badge")

            ; window setup
            new_badge := Gui(, "Badge")
            new_badge.Opt("+AlwaysOnTop")
            new_badge.SetFont("s18 w700", "Arial")

            ; text setup
            new_text := new_badge.AddText()
            new_text.Move(0, , Badge.TOOLTIP_WINDOW_WIDTH, Badge.TOOLTIP_WINDOW_HEIGHT)
            new_text.Opt("Center")

            ; set positioning
            new_badge.Show() ; has to be shown to move
            position_y := (Badge.SCREEN_SCALED_HEIGHT - (Badge.SCREEN_SCALED_HEIGHT / 20)) - Badge.TOOLTIP_WINDOW_HEIGHT
            new_badge.Move( ; pos/size
                position_x,
                position_y,
                Badge.TOOLTIP_WINDOW_WIDTH,
                Badge.TOOLTIP_WINDOW_HEIGHT
            )
            new_badge.Hide()

            ; add to cache
            Badge.badge_cache[position_name] := new_badge
            Badge.text_cache[position_name] := new_text
        }
    }

    ; --- SHOW ---

    ; location is expected to be 'Right', 'Left', or 'Middle'
    ; color is expected to be an RGX hex code
    static ShowBadge(
        text, 
        location := "Middle",
        background := Badge.COLOR_BACKGROUND,
        foreground := Badge.COLOR_FOREGROUND
    ) {
        ; check if badge needs to be set up
        if (
            (Badge.badge_cache.Count == 0) 
            || (Badge.text_cache.Count == 0)
        ) {
            throw MethodError("Badge attempted to be shown before Badge has been initialized")
        }

        ; select position
        if (!Badge.position_names.Has(location)) {
            throw ValueError("location must be Left, Right, or Middle")
        }
        curr_badge := Badge.badge_cache[location]
        curr_text := Badge.text_cache[location]

        ; foreground/background color
        curr_text.Opt("c" foreground)
        curr_badge.BackColor := background

        ; change text
        curr_text.Text := text

        ; show and adjust
        curr_badge.Show("NA")

        ; destroy after delay
        Timer.Go(
            location, 
            () => curr_badge.Hide(),
            Badge.TOOLTIP_TIME_MS
        )
    }

    ; log if not the L mouse button
    static MsgBoxNoLButton(hotkey, text) {
        if (
            (hotkey != "$LButton")
            && (hotkey != "$LButton Up")
            && (hotkey != "LButton")
            && (hotkey != "LButton Up")
        ) {
            MsgBox(text)
        }
    }
}