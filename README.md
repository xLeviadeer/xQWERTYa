# xQWERTYa
The xQWERTYa layout system for xQWERTILE on Windows. xQWERTYa is an advanced inheritance-centric, data-driven and portable-concious AHK (V2) based input remapping system. 

## Why Use xQWERTYa
The core principles of xQWERTYa are ⌄
1. data-driven — xQWERTYa is data-driven using `.json` files for customization.
    - xQWERTYa doesn't lose the power of AHK: you can make calls to your cutom AHK functions from within the `.json` configuration.
2. inheritance-centric — xQWERTYa works on a model of ⸉Profiles⸉ and inheritance, where you can create different layouts and then mix components of different layouts with each other so you don't need to duplicate your keybinding logic.
3. Portability — xQWERTYa is intended to be able to easily be built into an EXE using the Ahk2Exe AHK module so you can bring your custom keyboard layout with you on the go on something as small as a USB drive.

In addition to these principles xQWERTYa has many benefits over a typical QWERTY keyboard system ⌄
- xQWERTYa majorly expands what you are able to type using your keyboard
- xQWERTYa comes in with several built-in extra modifier keys for binding extra characters to such as Curl, Elevate & Shelve
- Key bindings in xQWERTYa are very powerful
    - Keys can inherit from different profiles
    - Keys can mime other keys and use their inheritance tree
    - Keys can call your custom AHK code functions
    - and more
- xQWERTYa uses a unified ⸉Profiles⸉ system for context switching which change the keyboards how it acts when pressing keys
    - Profiles can inherit from other profiles, creating an inheritance tree
    - Profiles can be quickly switched into while holding a button down to change actions on the fly
    - and more

## How to Use xQWERTYa 
**xQWERTYa is a complex system. Please read the [documentation](./docs/Index.md) to understand how to use xQWERTYa**. Read the known limitations [here](./docs/Limitations.md).

### EXE (most users)
1. Download the [latest releases's](../../releases) `.zip`.
2. Extract the contents to a new directory.
3. Open the `keybinds/` folder and [start your first binding](#create-your-first-binding).
4. Run xQWERTYa by double-clicking on `Main.exe` or `Main_Admin.exe` to run as an admin. 

### AHK (for tinkerers)
If you intend to run xQWERTYa with Method Calls or use advanced functionality you will need to use this option.
1. [Download AHK 2.0](https://www.autohotkey.com/) and install it on your computer.
2. Clone this repo.
3. Open the `keybinds/` folder and [start your first binding](#create-your-first-binding). 
4. Run xQWERTYa by double-clicking on `Main.ahk` or `Main_Admin.ahk` to run as an admin. 

### Create Your First Binding
1. In `keybinds/` and create a `.json` file named as the [AHK V2 key name](https://www.autohotkey.com/docs/v2/KeyList.htm) of the key you are rebinding. For example `a.json` will be intended to rebind the key ⸢a⸥.
2. Write a default profile binding, for example: 
```json
{
    "target": "a", 
    "default": "b"
}
```
- More examples can be found [under the samples directory](./docs/Samples/) starting at [a](./docs/Samples/keybinds/a.json), [b](./docs/Samples/keybinds/b.json), and [c](./docs/Samples/keybinds/c.json).

## Documentation
You can read the documentation [here, under `docs/`](./docs/Index.md).