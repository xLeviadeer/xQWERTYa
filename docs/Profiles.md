# Profiles
xQWERTYa uses ⸉profiles⸉ to allow the creation of separate modes of operation for the keyboard. For example: one profile may bind ⸢a⸥ to ⸢b⸥ but another may rebind ⸢a⸥ to ⸢c⸥. And the button ⸢g⸥ swaps from one profile to the other. Depending on the active profile, ⸢a⸥ will either result in ⸢b⸥ or ⸢c⸥. 

Profiles are simple but may become complex as they are customized. All profiles must be defined in `config/profiles.json`. Except for the `default` profile which always exists, cannot be re-defined in `profiles.json` and has a set of default characteristics. An example `profiles.json` with two simple profiles ⌄
```json
[
    {
        "id": "profile_one",
        "name": "Profile One"
    },
    {
        "id": "profile_two",
        "name": "Profile Two"
    }
]
```

**Profile attributes are ¡not¡ inherited.**

## Attributes
A list of possible attributes that may exist on a profile are detailed as follows

### ID
- required — yes
    - default profile value — `"default"`
- keyword — `id`
- value type — string
- description — the string which is used to identify this profile in keybindings, inheritance, etc.

### Name
- required — yes
    - default profile value — `"default"`
- keyword — `name`
- value type — string
- description — the name to show when switching to this profile

### Inherits From
- required — no
    - defaults to `"default"` if unspecified
- keyword — `inheritsFrom`
- value type — string
- description — the profile for which this profile should inherit from
    - this profile will work as a copy of the inherited profile ¡except¡ for where new behavior has been layered on top of (to hide) the existing behavior

### Modifier Passthrough
- required — no
    - defaults to ⌄ if unspecified
    ```json
    {
        "shift": true,
        "control": true,
        "curl": false,
        "alt": false,
        "elevate": false,
        "shelve": false,
        "step": false,
        "windows": false
    }
    ```
- keyword — `modifierPassthrough`
- value type — dictionary\<string, boolean>
- description — whether to allow Windows to see that a modifier is being held down for each modifier key
    - shift being true means that pressing ⟨shift⟩ & ⸢a⸥ will result in a program observing keystrokes to see ⟨shift⟩ & ⸢a⸥. If it were set to false the program observing keystrokes would only see ⸢a⸥.

### Exeptions 
- required — no
    - defaults to `false` (meaning no exceptions) if unspecified
- keyword — `exceptions`
- value type — list\<str> or false
- description — keys to completely disable keybinding on in this profile
    - some keys won't behave right despite different ways of binding a key. To get around this you can add keys to the exceptions in a profile which will ensure that they work normally. 

### Hidden
- required — no
    - defaults to `false` if unspecified
- keyword — `hidden`
- value type — boolean
- description — whether to hide|skip this profile in the `Profile.Cylce()` method

### Compatibility
- required — no
    - defaults to `false` if unspecified
- keyword — `compatibility`
- value type — boolean
- description — whether the compatibility lock is silently enabled/disabled when entering this profile

### Based
- required — no
    - defaults to `false` if unspecified
    - default profile value — `true`
- keyword — `based`
- value type — boolean
- description — whether this profile's passthrough bindings use `base` behavior (see [Base (binding level)](./keybinds.md#base-binding-level)).

### Collapse
- required — no
    - defaults to `false` if unspecified
    - default profile value — `true`
- keyword — `collapse`
- value type — boolean
- description — whether this profile's passthrough bindings use `collapse` behavior (see [Collapse (binding level)](./keybinds.md#collapse-binding-level)).

### Else
- required — no
    - defaults to `false` if unspecified
- keyword — `else`
- value type — boolean
- description — whether this profile's passthrough bindings use `else` behavior (see [Else (binding level)](./keybinds.md#else-binding-level)).

### Blind
- required — no 
    - defaults to `true` if unspecified
- keyword — `blind`
- value type — boolean
- description — whether to send all keybinds from this profile as [`{Blind}` in AHK](https://www.autohotkey.com/docs/v2/lib/Send.htm#blind)

### Color
- required — no
    - defaults to `000000` if unspecified
- keyword — `color`
- value type — string hex color code
- description — the color to show the name of this profile as when switching to this profile

### Show Badge
- required — no
    - defaults to `true` if unspecified
- keyword — `showBadge`
- value type — boolean
- description — whether to show the the profile switch badge when switching to this profile

### Disables Letters
- required — no
    - defaults to `false` if unspecified
- keyword — `disablesLetters`
- value type — boolean
- description — Whether this profile should show a warning and do nothing when attempting to type with letter keys on this profile which are not inherited and are otherwise undefined 
    - the program will automatically switch into the default profile if enough letter keys are pressed
    - this is mostly a legacy system left in for compatibility

### Quick Switch
- required — no
    - defaults to `false` if unspecified
- keyword — `quickSwitch`
- value type — boolean
- description — Sets this profile to be a quick switching profile. 
    - Optimizes the profile to be switched to (and from) faster.
        - new profile ⚷ the profile being switched to | the profile with quick switching 
        - old profile ⚷ the profile being switched from | profile that may or may not have quick switching
    - Quick-switching can ¡only¡ work ¡if¡ the following requirements can be met. If not, then quick-switching ¡will¡ create bugs and possible crashes. 
        - new profile compatibility will ¡always¡ match the old profile compatibility
        - new profile passthrough will ¡always¡ match the old profile passthrough
        - new profile exceptions will ¡always¡ match the old profile exceptions
    - Quick-switching is useful for profiles which are meant to be quickly swapped to briefly while using another profile╌generally, while holding a key down.

---
[back to index](./Index.md)