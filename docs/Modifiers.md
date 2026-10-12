# Modifiers
xQWERTYa defines certain keys on the keyboard as restricted keys that are used as ⸉modifiers⸉. ⸉modifiers⸉ are keys like ⟨Shift⟩ & ⟨Control⟩ which ⸉modify⸉ what a keypress does. Like how pressing ⸢a⸥ types a but holding ⟨Shift⟩ & ⸢a⸥ types a capitol ⸢A⸥. 

## Modifier Configuration
Modifiers are customizable properties. They must be defined in `config/modifiers/modifiers.json`. An example `modifiers.json` with two simple modifiers ⌄.
```json
[
    {
        "name": "shift",
        "priority": 10,
        "target": "LShift",
        "alternates": ["RShift"]
    },
    {
        "name": "windows",
        "priority": 20,
        "target": "LWin",
        "alternates": ["RWin"],
        "lone_action": "Windows" 
    }
]
```
In the example a modifier named `shift` is created and bound to `LShift` and `RShift` & a modifier named `windows` is created and bound to `LWin` and `RWin`. `windows` is given the built-in `lone_action` (only occurs if the modifier is released ⦅alone | in combination with nothing else⦆) `Windows` which presses the Windows key. 

By default xQWERTYa comes with ⌄ bindings in `modifiers.json`. However, these bindings can be changed. 
- Left Control → Control
- Left Shift → Shift
- Left Alt → (replaced by) Elevate
- Left Windows → (replaced by) Shelve
- Right Control → (replaced by) Windows
- Right Shift → (replaced by) nothing | a normal key
- Right Alt → Alt
- Right Windows → Windows
- CapsLock → (replaced by) Curl

All modifiers have an acompanying `_up` binding which is the action that takes place when the key is released. `_up` bindings are attempted to be automatically generated when they are not present. xQWERTYa will throw an error if it cannot create determine an `_up` binding for a given down binding. In this case an explicity `_up` binding should be written

Modifier ⸉combinations⸉ are generated via the priority system to be used on key-profiles. Modifiers with lower priorities must come first. Modifiers are separated by underscores. For example, given the modifiers above ⌄ are valid combinations.
- `shift`
- `windows`
- `shift_windows`

But, `windows_shift` is an invalid combination because it does not increase in priority (20⧼ for `windows`⧽is not less than 10⧼ for `shift`⧽).

## Attributes
A list of possibles that may exist on a modifier are detailed as follows.

### Name
- required — yes
- keyword — `name`
- value type — string
- the string which is used to identify this modifier in keybindings. 

### Priority
- required — yes
- keyword — `priority`
- value type — integer
- description — the priority in the composition order for this modifier.
    - two modifiers cannot share the same priority
    - a modifier with a lower priority appears before other modifiers in string combination form ⌄
        - given modifier `shift` with priority 10 & modifier `windows` with priority 20: the combination would be required as `shift_windows`.

### Target
- required — yes
- keyword — `target`
- value type — string [AHK V2 key name](https://www.autohotkey.com/docs/v2/KeyList.htm) 
- description — the target key for which to bind this modifier to. 

### Alternates
- required — no
    - defaults to `false` if unspecified
- keyword — `alternates`
- value type - list of string [AHK V2 key names](https://www.autohotkey.com/docs/v2/KeyList.htm)
- description — a list of additional keys to bind this modifier to.

### Else
- required — no
    - defauls to `false` if unspecified
- keyword — `else`
- value type — string matching one of ⌄
    - `#` meaning Windows
    - `!` meaning Alt
    - `^` meaning Control
    - `+` meaning Shift
- description — what modifier this key should act like when [else behavior](./Profiles.md#else) is used. 

### Lone Action
- required — no
    - defaults to `false` if unspecified
- keyword — `lone_action`
- value type — string function name or `false` (meaning none)
- description — the name of AHK method located in `config/locks/ModifierActions.ahk` to run when this modifier is released without pressing anything else with it.
    - only built-in methods can be used if running in EXE mode. 

### Down Action
- required — no
    - defaults to `false` if unspecified
- keyword — `down_action`
- value type — string function name or `false` (meaning none)
- description — the name of AHK method located in `config/locks/ModifierActions.ahk` to run when this modifier is released.
    - only built-in methods can be used if running in EXE mode. 

### Up Action
- required — no
    - defaults to `false` if unspecified
- keyword — `up_action`
- value type — string function name or `false` (meaning none)
- description — the name of AHK method located in `config/locks/ModifierActions.ahk` to run when this modifier is pressed.
    - only built-in methods can be used if running in EXE mode. 

---
[back to index](./Index.md)