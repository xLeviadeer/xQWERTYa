# Modifiers
xQWERTYa defines certain keys on the keyboard as restricted keys that are used as ⸉modifiers⸉. ⸉modifiers⸉ are keys like ⟨Shift⟩ & ⟨Control⟩ which ⸉modify⸉ what a keypress does. Like how pressing ⸢a⸥ types a but holding ⟨Shift⟩ & ⸢a⸥ types a capitol ⸢A⸥. 

⌄ is a list of modifier mappings in xQWERTYa 
- Left Control → Control
- Left Shift → Shift
- Left Alt → (replaced by) Elevate
- Left Windows → (replaced by) Shelve
- Right Control → (replaced by) Windows
- Right Shift → (replaced by) a default mappable key
- Right Alt → Alt
- Right Windows → Windows
- CapsLock → (replaced by) Curl
- SC073 → Step

All modifiers have an acompanying `_up` binding which is the action that takes place when the key is released. `_up` bindings are attempted to be automatically generated when they are not present. xQWERTYa will throw an error if it cannot create determine an `_up` binding for a given down binding.

All modifiers are bindable at the key level in `.json` via a specific keyword. Many bindings can also be used as combinations. A list of existing modifier keywords is ⌄ . 
- `shift`
    - `shift_control`
    - `shift_curl`
    - `shift_alt`
        - `shift_alt_elevate`
    - `shift_elevate`
    - `shift_shelve`
    - `shift_step`
- `curl`
- `alt`
    - `alt_elevate`
- `control`
- `shelve`
- `elevate`
- `step`
- `windows`

---
[back to index](./Index.md)