# Locks
xQWERTYa may use a set of ⸉Locks⸉ which are states that work like how caps-lock works on a typical QWERTY keyboard. They are intended to be [triggered via a binding](./keybinds.md#toggle-lock). Locks are distinctly toggle-based (switch on, switch off). The [sample binding for locks](./Samples/config/locks/locks.json) includes only an example lock for caps-lock. And a usage example can be found in the key ⸢d⸥. 

## Lock Configuration
Locks are customizable properties. They must be defined in `config/locks/locks.json` except for the `compad` lock which always exists, cannot be re-defined in `locks.json` and has a set of un-changable characteristics. An example `locks.json` with two simple locks ⌄
```json
[
    {
        "name": "caps",
        "priority": 10,
        "starts_locked": false,
        "badge_text": "Caps Lock"
    },
    {
        "name": "num",
        "priority": 20,
        "starts_locked": false,
        "badge_text": "Num Lock"
    }
]
```

The built-in compatibility lock is a lock used to determine whether or not to make extra checks against the physical key state when pressing and releasing keys. It is not suitable for complex multi-binding situations like playing games. Though, helps with stability in typing situations.

## Key-Modifiers
To make use of defined locks a key-modifier must be created on a key, under a profile on a modifier. A key-modifier defines the behavior of a lock under existing narrowed conditions. An example key-modifier definition using the `locks.json` configuration above ⌄.
```json
{
    "target": "a",
    "default": {
        "default": {
            "default": "a",
            "caps": "A"
        },
        "shift": {
            "default": "A",
            "caps": "a"
        }
    }
}
```
The outermost `"default"` is targeting the default profile. The middle `"default"` is targeting the default (no-)modifier. The innermost `"default"` is targeting the default (no-)lock. A key-modifier is the contents of the object associated with the default (no-)modifier and the `shift` modifier. The following statements are true given the binding above ⌄
- when in the `default` profile, ⧼when no modifiers are being pressed, ⧽no locks are active, and ⸢a⸥ is pressed: ⸉a⸉ will be typed. 
- when in the `default` profile, ⧼when no modifiers are being pressed, ⧽caps lock is active, and ⸢a⸥ is pressed: ⸉A⸉ will be typed.
- when in the `default` profile, when shift is being pressed, no locks are active, and ⸢a⸥ is pressed: ⸉A⸉ will be typed.
- when in the `default` profile, when shift is being pressed, caps lock is active, and ⸢a⸥ is pressed: ⸉a⸉ will be typed. 

## Lock Resolution
Locks behave with internal-only resolution behavior that ties into (outer) modifier behavior | lock behavior works entirely within itself without considering the outer behavior settings for profiles, modifiers, and the key. Locks are resolved by finding the highest order lock binding instance defined on the key-modifier for the current active locks. Take the example ⌄ where the locks defined in `locks.json` at the top of this file exist.
```json
{
    "target": "a",
    "default": {
        "default": {
            "default": "a",
            "caps": "A"
        }
    }
}
```
Say that `caps` lock is active: then `"caps": "A"` will be used╌no suprised. However, say that `caps` ¡and¡ `num` locks are both active. In this circumstance `"caps": "A"` is the ⸉highest⸉ fitting binding and will hence be used | the binding for `"caps": "A"` is the largest binding that fits in the composition of `caps` and `num` so it is used. Larger fitting compositions are prioritized over smaller ones. If two compositions are equally large the composition with higher priority is choosen. This behavior is not effected by any configuration of [basing](./Profiles.md#based) or [collapsing](./Profiles.md#collapse). 

## Attributes
A list of possibles that may exist on a lock are detailed as follows. 

### Name
- required — yes
- keyword — `name`
- value type — string
- description — the string which is used to identify this profile in keybindings. 

### Priority
- required — sometimes
    - if the lock is [bindable](#bindable) then priority is ¡not¡ required. In all other cases priority is required. 
- keyword — `priority`
- value type — integer
- description — the priority in the composition order for this lock.
    - two locks cannot share the same priority
    - a lock with a lower priority appears before other locks in string combination form ⌄
        - given lock `caps` with priority 10 & lock `num` with priority: the combination would be required as `caps_num`.
    - priority may be used to resolve conflicts a key-modifier structure.

### Starts Locked
- required — no
    - defaults to `false` if unspecified.
- keyword — `starts_locked`
- value type — boolean
- description — whether this lock starts as locked when the program starts.

### Bindable
- required — no
    - defaults to `true` if unspecified.
- keyword — `bindable`
- value type — boolean
- description — whether this lock can be bound to in key-profiles. 
    - if false then [priority](#priority) does not need to be set.

### Change Action
- required — no 
    - defaults to `false` if unspecified.
- keyword — `change_action`
- value type — a string function name or `false` (meaning none)
- description — the name of AHK method located in `config/locks/LockActions` to run when this lock changes state. 
    - only built-in methods can be used if running in EXE mode. 

### Show Badge
- required — no
    - defaults to `true` if unspecified.
- keyword — `show_badge`
- value type — boolean
- description — whether to show the badge for this lock when it changes states.

### Badge Side
- required — no
    - defaults to `Right` if unspecified
- keyword — `badge_side`
- value type — a string matching one of ⌄
    - `"Right"`
    - `"Middle"`
    - `"Left"`
- description — the placement for the badge ([if shown](#show-badge)).

### Badge On Color ⧼Foreground⧽
- required — no
- keyword — `badge_on_color`
- value type — string hex color code
- description — the color to show for the text of this badge when it turns on.

### Badge Off Color ⧼Foreground⧽
- required — no
- keyword — `badge_off_color`
- value type — string hex color code
- description — the color to show for the text of this badge when it turns off.

### Badge On Color Background
- required — no
- keyword — `badge_on_color_bg`
- value type — string hex color code
- description — the color to show for the background of this badge when it turns on.

### Badge Off Color Background
- required — no
- keyword — `badge_off_color_bg`
- value type — string hex color code
- description — the color to show for the background of this badge when it turns off. 

---
[back to index](./Index.md)