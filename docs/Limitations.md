# Known Limitations
The limitations below come from the fact that xQWERTYa is developed in AHK (V2). Solutions to xQWERTILE key remapping using different underlying languages and systems may be explored in the future. 
- Because of how AHK V2 interfaces with Windows╌rarely╌modifier keys will get stuck down until pressed again.
    - Running xQWERTYa without admin increases the frequency at which keys get stuck.
    - Running xQWERTa on a PC with less spare performance increases the frequency at which keys get stuck.
- Computers without decent performance will lag significantly when using xQWERTYa when they are already heavily taxed.
- xQWERTYa cannot overwrite core Windows bindings such as Win + L, Ctrl + Shift + Esc, Ctrl + Alt + Del.
    - xQWERTYa has a builtin secondary key that can act as the Windows key bound to SC070.
    - The Windows key(s) can be scanmap rebound to SC073 which will stop it from triggering Windows binds like Win + L. 
- Very rarely╌for an unknown reason╌xQWERTYa will freeze input
    - if not running as admin: open Task Manager via Ctrl + Alt + Del and kill AHK to escape
    - if running as admin and a kill bind hasn't been configured: the user may need to sign out to escape

---
[back to index](./Index.md)
╎ [back to README](../README.md)