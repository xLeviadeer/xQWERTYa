#Requires AutoHotkey v2.0

; creates a one-shot timer which can have it's remaining time adjusted by calling go again with a new duration
; timers are identified with id, a new timer is created if an ID is not found
; do ⊰not⊱ create new Timer object; use the go function to create new Timers.
class Timer {

    ; --- VARIABLES ---

    static resolution => 50

    static List := Map()

    ;constructed callback;
    ;constructed remaining;
    ;constructed timer_func;

    ; --- CONSTRUCTOR ---

    __New(id, callback, duration) {
        this.id := id
        this.callback := callback
        this.remaining := duration
        this.timer_func := ObjBindMethod(this, "_Tick")
    }

    ; --- METHODS ---

    ; sets a timer's callback and duration by id
        ; if a timer with same id exists already it 
            ; does not change the callback
            ; updates the duration to the given duration
            ; sets remaining to the new duration
    static Go(id, callback, duration) {
        ; get timer object
        if (Timer.List.Has(id)) {
            ; gets timer and updates remaining
            curr_timer := Timer.List[id]
            curr_timer.remaining := duration
        } else {
            ; creates a new running timer
            Timer.List[id] := Timer(id, callback, duration)
            SetTimer(
                Timer.List[id].timer_func,
                Timer.resolution
            )
        }
    }

    _Tick() {
        if (this.remaining <= 0) {
            this._Stop()
            return
        }
        this.remaining := this.remaining - Timer.resolution
    }

    _Stop() {
        this.callback.Call()
        SetTimer(this.timer_func, 0)
        Timer.List.Delete(this.id)
    }
}
