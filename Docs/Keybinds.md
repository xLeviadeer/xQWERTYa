# Keybinds
xQWERTYa uses ⸉keybinds⸉ to bind specific keys. Each keybind has an expected structure. Each keybind is a single `.json` file in the `./keybinds` folder including ⌄
1. a ⸉target⸉ key to remap.
2. a key-profile; a dictionary of profiles which the key and profile has associated ⸉bindings⸉ for. Key-profiles must be profiles that exist in `profiles.json` (see [Profiles](./Profiles.md)).

A ⸉**binding**⸉ is a singular mapping which specifies ⌄
1. the key that is remapped (via the target of the keybind).
2. the profile for which the mapping takes place under.
3. the modifiers that must be pressed alongside the target to trigger the mapping.
4. the associated action to take when the above circumstances are fulfilled.

⌄ is a sample keybind.
```json
{
    "target": "a",
    "default": {
        "default": "b",
        "shift": "B"
    }
}
```
In the ⌃ example the key ⸢a⸥ is bound to ⸢b⸥. The value for key `"target"` is an  [AHK V2 key name](https://www.autohotkey.com/docs/v2/KeyList.htm) corresponding to the key to be rebound. The outer `"default"` is the the container holding all bindings for the `default` profile. The inner `"default"` is the binding for the key (⸢a⸥) when no modifiers are being pressed. `"shift"` is the binding for the key (⸢a⸥) when shift is being held on the keyboard and ⸢a⸥ is pressed. 

## Binding Sets
A binding is considered to fall under different numeric categorizations depending on how many keys must simultaneously be pressed to activate it ⌄
- a single binding is a binding with one component (which will always be the target) (ex. `default` includes only the target.)
- a double binding is a binding with two components (ex. `shift` inclues shift and whatever the target is).
- a triple binding is a binding with three or more components (ex. `shift_control` includes shift, control and whatever the target is).

## Unsafe & Strict
A keybind may (optionally) have the following attributes ⌄ (positioned sitting next to `"target"`) which are intended to ⊰not⊱ be used unless they are needed for compatibility for a specific configuration.
- `"unsafe": instance-of bool`
    - defaults to `false`
    - allows the kebind to loop, possibly causing infinite recursion if not bound carefully
- `"strict": instance-of bool`
    - defaults to `false`
    - sets key to not accept any modifiers
    - key cannot have an up action

## Actionable Attributes
Actionable attributes are attributes whose value corresponds with an ⸉action⸉. An action is an effect that can be triggered via a binding that follows a custom syntax system. 

### Default & Modifier Attributes
A key-profile includes bindings which correlate directly with an action. A modifier binding may be any valid value out of the list in [Modifiers](./Modifiers.md) with the addition of `default`. `default` describes the default action when no modifiers are being pressed. 

### Lock Attributes
A key-profile may include a binding for different [locks from the Locks list](./Locks.md) which bind an action to pressing a key while a lock is active. 

Lock bindings will base to non-lock bindings if a lock binding is not present. Binding ⸢a⸥ to ⸢b⸥ and enabling arrow-lock does not cause ⸢a⸥ to stop typing ⸢b⸥ because the lack of a lock binding on ⸢a⸥ signals that the default non-lock binding should be used instead ⧼of doing nothing⧽.

### Action Values
#### Passthrough
- syntax — `true`
- description — acts according the logic specified by the profile configuration, and key-profile behavior configuration, passing logic outside of this binding. In simplistic cases this can be thought of as inheritance, where the binding inherits it's behavior rather than doing anything.
- this is the default action value of any binding which has not been explicitly set on a keybind (ex. not setting `"shift":` in a profile would result in the value implicitly being set as `"shift": true`).
    - in the `default` profile╌if `inherits_from` is not set╌this is not true as any binding which has not been explicitly set╌instead╌does nothing since there is nothing to pass through to.

#### Do Nothing
- syntax — `false`
- description — sets this binding to do nothing | when activating the binding nothing happens. 

#### Direct Method Call
- syntax — not applicable
    - a direct method call can only be set manually in `.ahk` code via the `Key.Create()` method by creating a `KeyProfile` as part of the `profiles` list and setting the value of a binding to be a method. 
- description — sets a binding to be a code method.

#### Method Call
- syntax — `"@‹identifier›"`
- description — sets the binding to call a method of name matching `‹identifier›` from a matching `.ahk` target file.
    - Read [Custom Keys](./Custom_Keys.md) to see how to create your own method call ⧼& target structure⧽.

#### Toggle Lock
- syntax — `"<‹lock›"`
- description — toggles a lock (see [Locks](./Locks.md)) on/off. `‹lock›` is expected to be a [valid lock name](./Locks.md).

#### Profile Switch
- syntax — `">‹profile id›"`
- description — switches to the profile with the profile id matching `‹profile id›`. 

#### Profile Cycle
- syntax — `"ⓝcycle"`
- description — cycle through non-hidden profiles (see [hidden profiles](./Profiles.md#hidden)) in the order they appear in `profiles.json`.

#### Else (binding level)
- syntax — `"ⓝelse"`
- description — pass this binding through to Windows.
    - Ex. Making a keybind targeting ⸢a⸥ and setting `"shift": "ⓝelse"` in the `default` profile will rebind pressing shift & ⸢a⸥ to shift & ⸢a⸥. Notice there is no change between what is being rebound and the result.

#### Base (binding level)
- syntax — `"ⓝbase"`
- description — use ⸉based⸉ behavior for this binding only (see [Profiles](./Profiles.md#based)).
    - only works if the specified binding is a triple ⧼or more⧽ binding.
- basing priority — basing uses a priority system to determine the ⸉strongest⸉(|highest priority) base
    - priority ⌄
        - shift ⧙strongest⧘
        - control
        - curl
        - alt
        - elevate
        - shelve
        - step
        - windows ⧙weakest⧘
    - Ex. `shift_alt_elevate` bases to `shift` because `shift` is the highest priority base. 

#### Collapse (binding level)
- syntax — `"ⓝcollapse"`
- description — use ⸉collapse⸉ behavior for this binding only. set the binding to act like the `default` binding in this key-profile.

#### Reload
- syntax — `"ⓝreload"`
- description — reload the program | kill & restart the program

#### Kill
- syntax — `"ⓝkill"`
- description — kill the program

#### Mouse Click
- syntax — `"=‹button›, ‹x›, ‹y›, ‹count›, ‹speed›, ‹state›, ‹relative›"`
- description — perform a mouse click with arguments corresponding to [AHK's documentation](https://www.autohotkey.com/docs/v2/lib/MouseClick.htm).

#### ⧼String⧽ Binding
- syntax — `"‹bind›"`
- description — create an AHK binding with the right side being this string.
    - is typically a string such as `"a"` or `"b"` but may be any [AHK V2 key name](https://www.autohotkey.com/docs/v2/KeyList.htm).
    - most [AHK Send features](https://www.autohotkey.com/docs/v2/lib/Send.htm) are available such as ⧼but not limited to⧽ ⌄
        - calling down or up (Ex. `"{a Down}"`).
        - calling groups of actions (Ex. `"{LShift Down}{a Down}{a Up}{LShift Up}"`).
        - using blind and raw (Ex. `"{Blind}{a}"` or `"{Raw}{a}"`).
        - using modifier shortcuts (Ex. `"+a"` meaning shift & ⸢a⸥).
- this is the most prevalent action value

### Down Tracking
Down tracking is a setting for a binding which forces the xQWERTYa program to manually track the position of a key such that holding the key does ¡not¡ repeatedly emit the down binding action when held. 

Down tracking is used by prepending a json-string-based value with an underscore|`_`. To get a raw underscore wrap the underscore in curly braces as per usual AHK convention (ex. `{_}`).

Most of the time Windows will handle whether or not the action should be repeated based on the context (ex. typing repeats pressing a, but in games a is not repeated). But in situations where Windows is not the action operator (such as a⧼n AHK⧽ method call) the action will be repeatedly called.

⌄ a binding without down tracking. In the example when ⸢a⸥ is held `my_method` will be repeatedly called.
```json
{
    "target": "a",
    "default": {
        "default": "@my_method"
    }
}
```

⌄ a binding with down tracking. In the example when ⸢a⸥ is held `my_method` is called once when the key is pressed down.
```json
{
    "target": "a",
    "default": {
        "default": "_@my_method"
    }
}
```

## Behavior Attributes
In addition to modifier bindings a key-profile may include several behavior flags which alter how the key will behave in the specified profile. A list of available behavior flags ⌄

### Inherits From
- syntax — `"inherits_from": "‹profile id›"`
- description — sets this key-profile's passthrough bindings to inherit from a different key-profile on the same key. `‹profile id›` is expected to be the profile for which to inherit from.

### Uses
- syntax — `"uses": "‹target›"
- description — sets this key-profile's passthrough bindings to use behavior from the same key-profile on a different key target. `‹target›` is expected to be the target of an existing keybind. 
    - uses may be ⸉raw⸉ via prefixing the target with a tilde `~`. This is useful for cases like sending 1—the key—where, 1 would normally be interpreted by AHK as a number.

### Uses Profile
- syntax — `uses_profile": "‹profile id›"`
- description — sets this key-profile's passthrough bindings to use behavior from a different key-profile on the key set by `uses`. `‹profile id›` is expected to be the profile for which to inherit from.
    - `uses_profile` sets the profile at the same time as `uses` rather than after `uses` (which is what `inherits_from` does). This is useful if you want to select both a profile and target at the same time. With `inherits_from` + `uses` the order would only allow the foremore priority selection to be made. 
        - Ex. `"uses": "a"` & `"inherits_from": "other_profile"` would ignore `other_profile` becuase `uses` occurs before `inherits_from`
        - Ex. `"uses": "a"` & `"uses_profile": "other_profile"` would both change target (to ⸢a⸥) and the profile (to `uses_profile`).

### Else (profile level)
- syntax — `"else": ⓘbool`
- default — `false`
- description — sets whether this key-profile's passthrough bindings use else behavior (see [Else (binding level)](#else-binding-level)).

### Based (profile level)
- syntax — `"based": ⓘbool`
- default — `false`
- description — sets whether this key-profile's passthrough bindings use base behavior (see [Base (binding level)](#base-binding-level)).

### Collapse (profile level)
- syntax — `"collapse": ⓘbool`
- default — `false`
- description — sets whether this key-profile's passthrough bindings use collapse behavior (see [Collapse (binding level)](#collapse-binding-level)).
    - Ex. consider the ⌄ keybind. Assume `other_profile` inherits from `default`.
    ```json
    {
        "target": "a",
        "default": {
            "default": "b",
            "shift": "sb"
        },
        "other_profile": {
            "collapse": true,
            "default": "c"
        }
    }
    ```
    - pressing shift & ⸢a⸥ while in `other_profile` will type ⸢c⸥ because╌instead of inheriting `shift` behavior from `default`╌`shift` is collapsed to the `default` binding in `other_profile`, which is ⸢c⸥.

## Execution Order
Execution order is a technical concept. Sometimes understanding the execution order is important for understanding how your keypresses will route in behaviorally complex circumstances. 

The ⌄ is an order╌from top to bottom╌that occurs when interpretting a keystroke.
1. disabled letters check
	- if a letter is supposed to be disabled in a profile it will be disabled now
2. an interpretation loop starts; the following steps loop until default is hit or a valid action is found
	1. lock interpretation
		- if a lock is present it will be interpreted
		- locks ignore `else` treatment, inheritance, and uses: a lock will default to the default of the current key + profile + modifier if the lock isn't present
	2. nonexistent profile inheritance
		- if a profile doesn't exist it's inherited via profile settings
	3. modifier existence
		- if a modifier exists it will be executed
	4. collapse logic
		- collapse logic runs, changing the target modifier
	5. else logic
		- else logic runs, overriding uses and inheritance
	6. uses logic
		- uses logic runs, switching the key to target
		- uses profile logic runs, switching the profile to target
	7. nonexistent modifier inheritance
		- if a modifier doesn't exist it's attempted to be inherited
		- first from the key level inheritance
		- second from the profile level inheritance 
3. modifier execution
	- the modifier's value is executed on
	1. Switch over the primary type (boolean, string, action). When it's a string: 
		1. Down tracking is checked
        2. Check if using the special keywords (such as `ⓝcollapse`, `ⓝelse`, etc.)
        3. Mouse button is checked
        4. Profile switching is checked
		5. Method call is checked

---
[back to index](./Index.md)