New Features in CraftOS-PC v2.6.2:

* Bumped structure version to 6
  * New fields in `Computer`:
    * `openWebsocketServers`
  * New fields in `configuration`:
    * `dropFilePath`
  * New fields in `PluginFunctions`:
    * `registerPeripheralFn`
* Added ability to drop files to paste their paths instead of copying the file
  * Enabled using `dropFilePath` config setting
* Added single-window mode
  * Displays all computers on the same window
  * Activated with `--single` flag on CLI
  * Ctrl+Alt+Left/Right (Cmd+Option+L/R on Mac) to switch windows in GUI
* Added ability to copy screenshots on Linux (X11, Wayland)
* Added `registerPeripheralFn` capability to allow passing a function object
  * `registerPeripheral` is now deprecated
* Added brand-new UI on mobile devices (beta only)
  * Redesigned UI with navigation bar & hotkey toolbar above keyboard
  * Added support for computer, debugger, and monitor peripherals
  * Change windows using the arrows in the navigation bar
  * Automatic shell resizing makes sure you can see what you type
  * Added new launch screen (iOS)
  * The new UI is only available in beta builds at the moment due to bugginess
    * iOS: https://testflight.apple.com/join/SiuXlijR
    * Android: https://www.craftos-pc.cc/nightly/
* Improved WebSocket server functionality
  * Servers can now be properly opened by calling `http.websocket` with a port argument
  * Multiple clients to the same server now get unique identifiers as userdata values
* Improved quality of CCEmuX plugin
* CLI mode now uses Unicode characters for non-ASCII characters
* WebSocket text messages are now sent in UTF-8
* Improved Rednet deduplication efficiency (part of CC:T 1.99.0)
* cash no longer saves duplicate history entries
* Deprecated `peripheral::update` as it was never used
* Fixed crashing whenever opening a debugger (from crash reports)
* Fixed a crash when comparing two identical substrings (#218)
* Fixed a crash caused by force-closing a computer after it's already gone (from crash reports)
* Fixed a crash in `term.drawPixels` when passing a negative value (#224)
* Fixed occasional crashes from `get_comp` cache duplication (from crash reports)
* Fixed crashes and incorrect behavior when using `string.format` with substrings (from crash reports: @Creepi)
* Fixed strings in modem messages not being sent properly on Linux (@BytecodeEli)
* Fixed binary support in WebSocket messages
* Fixed an issue causing input to stop working in raw mode on Linux
* Fixed stack overflow when an error handler attempts to yield (from crash reports)
* Fixed a bug causing old `os` functions to be exposed (!)
* Fixed an incorrect error message when concatenating a concatenated string or substring with a value of an invalid type (@9551)
* Fixed an issue with completion for boolean config settings

Type "help changelog" to see the full version history.
