# Locks
xQWERTYa has a set of ⸉Locks⸉ which are states that work like how CapsLock works on a typical QWERTY keyboard. They are intended to be triggered via a binding and then change what a key does. 

Locks are intended to represent some common concepts
- Arrow Lock — changes the behavior of arrow or movement keys
- Capslock — changes the capitalization behavior of letter keys
- Numlock — changes the behavior of number keys
- Mouselock — changes the behavior of mouse keys
- Compatibility — a lock used to determine whether or not to make extra checks against the physical key state when pressing and releasing keys
    - not suitable for complex multi-binding situations like playing games
    - helps with stability in typing situations
- Real — a lock used to disabled all keybinds except the lock bind when active

Locks stay active when switching profiles╌however, lock behavior changes when switching profiles.

Locks can be triggered via a code function that calls `Locks.Set⌯()` or `Locks.Swap⌯()` from `Locks.ahk`. Or they can be toggled on/off directly using the [toggle lock action](./keybinds.md#toggle-lock). A list of valid names for toggle lock ⌄
- `arrow`
- `caps`
- `num`
- `mouse`
- `compad`
- `real`

Locks behavior is determined per-key via ⌄ keywords
- `arrowlock`
    - `arrowlock_shift`
        - `arrowlock_shift_control`
    - `arrowlock_elevate`
    - `arrowlock_control`
    - `arrowlock_windows`
- `capslock`
- `numlock`
- `mouselock`

---
[back to index](./Index.md)