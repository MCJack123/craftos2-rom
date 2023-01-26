New Features in CraftOS-PC v2.7.3:

* Updated CC:T version to 1.102.2
  * Moved Lua portions of `fs` and `http` outside the BIOS
  * Trim spaces from filesystem paths.
  * Fix `import.lua` failing to upload a file.
  * Reduce inconsistency with the table length operator in some cases
* Linux builds are now officially published as AppImages
  * These will be provided in conjunction with normal packages for Ubuntu/Arch/Raspbian
  * Arch users will be able to use `craftos-pc-bin` package to install the AppImage version, avoiding slow local compilation
* Replaced rope and substring allocation with clusters
  * This should hopefully fix performance and memory allocation issues with string concatenation
* Added new multi-touch events on mobile platforms
  * `_CCPC_finger_touch`, `_CCPC_finger_up`, `_CCPC_finger_drag`
  * All events get finger ID, X, and Y as parameters
  * These events co-exist with single-touch mouse events
* iOS now has Page Up/Down keys on the arrow toolbar for quicker navigation
* Added function authentication for C functions to mitigate bytecode vulnerabilities
* Improved performance of binary `file.readAll`
* `unpack` no longer uses a table's `n` field
* Fixed error when setting palette colors on windows in 256-color graphics mode
* Fixed more crashing when filesystem functions fail (#280)
* Fixed crashes due to stack overflows
* Fixed WebSocket pings sending a close response (#214)
* Fixed crashes in `websocket.receive()` when receiving a message that's too large (#297, #214)
* Fixed vague error message responses when an HTTP request fails (#292)
* Fixed DAP crash from setting a breakpoint in an unknown file
* Fixed breakpoints activating on the wrong line
* Fixed first line of a file not being able to trigger a breakpoint
* Fixed debugger errors when invalid arguments are used on the ccdb command line (#294)
* Fixed precision issues with `os.epoch("nano")` (#299)
* Fixed `rawlen` and `__ipairs` being missing from the global table
* Fixed Windows crash reporter being disabled
* Windows builds will no longer attempt to prompt for crash reporting when run in console-based modes
* Fixed some inconsistencies with seeking beyond a file's limits (#310)

Type "help changelog" to see the full version history.
