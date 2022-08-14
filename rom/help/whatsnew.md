New Features in CraftOS-PC v2.7:

* Bumped CC:T version to 1.100.9
  * Added basic WAV support to speaker.lua
* Added debug adapter for Visual Studio Code
  * This makes it possible to use VS Code's debugger interface with CraftOS-PC
  * Install the [CraftOS-PC extension](https://marketplace.visualstudio.com/items?itemName=jackmacwindows.craftos-pc) to use the debugger
* Added basic generic peripheral emulation
  * New peripheral types: `chest`/`minecraft:chest` (`inventory`), `tank` (`fluid_storage`), `energy` (`energy_storage`)
  * `tank` and `energy` may also have custom types set on them (for emulating compatible blocks from other mods)
  * See the full documentation for more info
* Rewrote filesystem code to use C++17 filesystem library
* Added ability to resize monitors programmatically, including by block size (#261)
* Added mounter sandboxing/path restriction (#104)
* Added `istailcall` field to `debug.getinfo`
* CLI mode now uses the Symbols for Legacy Computing block for bitmap characters (requires a font supporting Unicode 13)
* Adjusted configuration loading code to avoid crashes from invalid files
* Upgraded Windows project to Visual Studio 2022
* Fixed an issue on macOS causing HTTPS connections to fail
* Fixed constant crashes when launching the Android app
* Fixed "not enough memory" error when calling `string.rep` with a negative length
* Fixed require not working in --script/--exec
* Fixed a crash from invalid WebSocket data
* Fixed an HTTP issue causing the `Host` header to be set incorrectly when connecting to `localhost`
* Fixed a rendering issue when using a custom font with the hardware renderer
* Fixed `string.format("%q")` not accepting non-string arguments (#251)
* Fixed an issue causing raw mode to hang and use 100% CPU while exiting
* Fixed a typo in the `setGraphicsMode` argument checking code
* Fixed a crash when using `debug.getinfo(f, ">")`
* Fixed an overflow in `os.epoch` when using a 32-bit architecture
* CCEmuX plugin: Improved error message when `emu open` fails

Type "help changelog" to see the full version history.
