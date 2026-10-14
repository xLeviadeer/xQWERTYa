# Launch ⧼Configuration⧽
xQWERTYa's launch configuration can be modified in `config/launch.json`. **All values are ¡required to exist¡** for xQWERTYa to launch. 

## Attributes
### Cache Size
- keyword — `cache_size`
- value type — positive integer
- description — the amount of keybinds which can be held in the cache
    - xQWERTYa will store recently used keybinds so they don't have to go through a complex lookup loop on every keypress. But xQWERTYa is set to store a maximum number of keybinds in the cache to ensure memory isn't eaten up over time. The cache size is the limit. 
    - **a list with the size equal to the cache size is immediately allocated on launch**.
    - cache size may be set to 0 for no caching.

### Max Hotekeys Per Interval
- keyword — `max_hotkeys_per_interval`
- value type — positive non-zero integer
- description — the [AHK `A_MaxHotkeysPerInterval` value](https://www.autohotkey.com/docs/v2/lib/A_MaxHotkeysPerInterval.htm) for xQWERTYa to use.

### Process Priority
- keyword — `process_priority`
- value type — [AHK priority string](https://www.autohotkey.com/docs/v2/lib/ProcessSetPriority.htm)
- description — the [AHK priority string](https://www.autohotkey.com/docs/v2/lib/ProcessSetPriority.htm) corresponding to the process priority xQWERTYa should use.

### Admin
- keyword `admin`
- value type — boolean
- description — whether to run xQWERTYa as an admin.
