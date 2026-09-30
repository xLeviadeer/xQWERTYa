# Custom Keys
Custom keys is the system used for making method calls from `.json` configuration files.

**Method calls require an implementation of the ⸉Custom Keys Target Structure⸉**. You may opt to *construct your own target structure* or *download the pre-built target structure implementation*. **Most users should use the pre-built target structure implementation** unless they are tinkers who want to 

**Method calls *¡cannot¡* be made when using the `.exe` varation of xQWERTYa** unless you manually recompile your project with the updated code. To do so use the `Ahk2Exe` tool provided by AHK 2.0 and compile your project from whichever target of `Main.ahk` you prefer as you would any other AHK project. 

### ⟪I want to use the pre-built target structure implementation⟫
Copy the `PBTS` folder contents into the directory you are containing xQWERTYa in. 
- the contents of `keybinds` should go in your `keybinds` folder.
- `CustomKeys.ahk` should replace the existing `CustomKeys.ahk` file in your project (under `Key/`).

You can now make method calls.  

### ⟪I want to modify or make my own target structure implementation⟫
1. Create a key target file
    1. in whatever directory you'd like within the project (typically in `keybinds/`) create an `.ahk` code file (typically named the same as the key you will be targeting).
    2. create a collection class at top-level which contains a static variable `target` that has a value equal to a string with the [AHK V2 key name](https://www.autohotkey.com/docs/v2/KeyList.htm) of the key which you are mapping a method to. 
        - you may instead make a list of targets by naming the variable `targets` (as opposed to `target`) and setting the value to be a list of key names to target that map to this file. 
        - this file represents a collection of methods that can be called from the targetȿ.
2. Include your collection class 
    1. open `Key/CustomKeys.ahk`
    2. include your key target file via AHK 2.0's `#Include` system
    3. add your collection class to the `_customKeys` list

### Example
An example key target file located in `keybinds/a.ahk` ⌄
```ahk
class A {
    static target => "a"

    static my_method() {
        MsgBox("foo")
    }
}
```

An example `.json` configuration file containing a method call to `my_method` ⌄
```json
{
    "target": "a",
    "default": {
        "default": "@my_method"
    }
}
```

An example `CustomKeys.ahk` including only the changes ╎ **only required if manually implementing your own CustomKeys** ╎ changes are marked with the comment `; ADD THIS`
```ahk
#Include ../keybinds/a.ahk ; ADD THIS
...

; initializes all custom keys
;   needs to be updated with initializations as keys are added
class CustomKeys {
    ; --- VARIABLES ---

    static List := Map()

    ; this list is the one expected to be updated
    static _customKeys => [
        A ; ADD THIS
    ]

    ...
}
```

## PBTS table
| File Name   | Class Name         | Targets                                                                                                                                        |
|-------------|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| -           | Hyphen             | -                                                                                                                                              |
| ,           | Comma              | ,                                                                                                                                              |
| ;           | Semicolon          | ;                                                                                                                                              |
| .           | Period             | .                                                                                                                                              |
| '           | Apostrophe         | '                                                                                                                                              |
| [           | SquareBracketOpen  | [                                                                                                                                              |
| ]           | SquareBracketClose | ]                                                                                                                                              |
| `           | Backtick           | `                                                                                                                                              |
| =           | Equals             | =                                                                                                                                              |
| Numbers     | Numbers            | 0 1 2 3 4 5 6 7 8 9                                                                                                                            |
| Backslash   | Backslash          | \                                                                                                                                              |
| BackSpace   | BackSpace          | BackSpace                                                                                                                                      |
| Delete      | Delete             | Delete                                                                                                                                         |
| Enter       | Enter              | Enter                                                                                                                                          |
| Escape      | Escape             | Escape                                                                                                                                         |
| Insert      | Insert             | Insert                                                                                                                                         |
| Home        | Home               | Home                                                                                                                                           |
| Pause       | Pause              | Pause                                                                                                                                          |
| ScrollLock  | ScrollLock         | ScrollLock                                                                                                                                     |
| End         | End                | End                                                                                                                                            |
| PgDn        | PgDn               | PgDn                                                                                                                                           |
| PgUp        | PgUp               | PgUp                                                                                                                                           |
| PrintScreen | PrintScreen        | PrintScreen                                                                                                                                    |
| Slash       | Slash              | /                                                                                                                                              |
| Space       | Space              | Space                                                                                                                                          |
| Tab         | Tab                | Tab                                                                                                                                            |
| Directions  | Directions         | Up Down Left Right                                                                                                                             |
| MouseKeys   | MouseKeys          | RButton LButton MButton XButton1 XButton2 WheelUp WheelDown WheelLeft WheelRight                                                               |
| NumLock     | NumLock            | NumLock                                                                                                                                        |
| Numpad      | Numpad             | Numpad0 Numpad1 Numpad2 Numpad3 Numpad4 Numpad5 Numpad6 Numpad7 Numpad8 Numpad9 NumpadAdd NumpadDiv NumpadDot NumpadEnter NumpadMult NumpadSub |
| Functions   | Functions          | F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 F13 F14 F15 F16 F17 F18 F19 F20 F21 F22 F23 F24                                                         |
| AppsKey     | AppsKey            | AppsKey                                                                                                                                        |
| VirtualKeys | VirtualKeys        | VK0E VK0F VK3A VK3B VK3C VK3D VK3E VK3F VK40 VK97 VK98 VK99 VK9A VK9B VK9C VK9D VK9E VK9F VKE8                                                 |
| a           | a                  | a                                                                                                                                              |
| b           | b                  | b                                                                                                                                              |
| c           | c                  | c                                                                                                                                              |
| d           | d                  | d                                                                                                                                              |
| e           | e                  | e                                                                                                                                              |
| f           | f                  | f                                                                                                                                              |
| g           | g                  | g                                                                                                                                              |
| h           | h                  | h                                                                                                                                              |
| i           | i                  | i                                                                                                                                              |
| j           | j                  | j                                                                                                                                              |
| k           | k                  | k                                                                                                                                              |
| l           | l                  | l                                                                                                                                              |
| m           | m                  | m                                                                                                                                              |
| n           | n                  | n                                                                                                                                              |
| o           | o                  | o                                                                                                                                              |
| p           | p                  | p                                                                                                                                              |
| q           | q                  | q                                                                                                                                              |
| r           | r                  | r                                                                                                                                              |
| s           | s                  | s                                                                                                                                              |
| t           | t                  | t                                                                                                                                              |
| u           | u                  | u                                                                                                                                              |
| v           | v                  | v                                                                                                                                              |
| w           | w                  | w                                                                                                                                              |
| x           | x                  | x                                                                                                                                              |
| y           | y                  | y                                                                                                                                              |
| z           | z                  | z                                                                                                                                              |

---
[back to index](./Index.md)