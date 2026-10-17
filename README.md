# xQWERTYa
The xQWERTYa layout system for xQWERTILE on Windows. xQWERTYa is an advanced inheritance-centric, data-driven and portable-concious AHK (V2) based input remapping system. 

## Why Use xQWERTYa
Features ⌄
1. ⸉Profiles⸉ which switch what behavior a key uses for it's modifiers and locks. Profiles are unified across different devices.
2. ⸉Modifiers⸉ which are what are usually referred to as ⸉layers.
3. ⸉Locks⸉ which are toggled global states like ⸉caps-lock⸉ or ⸉num-lock⸉ on a typical keyboard.
4. Ability to break out into AHK code when xQWERTYa cannot meet your needs.
5. Ability to run the program portably on different Windows devices.

The core principles of xQWERTYa are as follows ⌄
1. data-driven — xQWERTYa is data-driven using `.json` files for customization.
2. inheritance-centric — xQWERTYa works on a model of ⸉Profiles⸉ and inheritance, where you can create different layouts and then mix components of different layouts with each other so you don't need to duplicate your keybinding logic.
3. customization — xQWERTYa is constructed on the idea of allowing for a large amount of customization

## How to Use xQWERTYa 
**xQWERTYa is a complex system. Please read the [documentation](./docs/Index.md) to understand how to use xQWERTYa**. Read the known limitations [here](./docs/Limitations.md).

### EXE (most users)
1. Download the [latest releases's](../../releases) `.zip`.
2. Extract the contents to a new directory.
3. Open the `config/keybinds/` folder and [start your first binding](#create-your-first-binding).
4. Run xQWERTYa by double-clicking on `Main.exe` or `Main_Admin.exe` to run as an admin. 

### AHK (for tinkerers)
If you intend to run xQWERTYa with Method Calls or use advanced functionality you will need to use this option.
1. [Download AHK 2.0](https://www.autohotkey.com/) and install it on your computer.
2. Clone this repo.
3. Open the `config/keybinds/` folder and [start your first binding](#create-your-first-binding). 
4. Run xQWERTYa by double-clicking on `Main.ahk` or `Main_Admin.ahk` to run as an admin. 

### Create Your First Binding
1. In `config/keybinds/` and create a `.json` file named as the [AHK V2 key name](https://www.autohotkey.com/docs/v2/KeyList.htm) of the key you are rebinding. For example `a.json` will be intended to rebind the key ⸢a⸥.
2. Write a default profile binding, for example: 
```json
{
    "target": "a", 
    "default": "b"
}
```
- More examples can be found [under the samples directory](./docs/Samples/) starting at [a](./docs/Samples/keybinds/a.json), [b](./docs/Samples/keybinds/b.json), [c](./docs/Samples/keybinds/c.json) and [d](./docs/Samples/keybinds/d.json).

## Documentation
You can read the documentation [here, under `docs/`](./docs/Index.md).
