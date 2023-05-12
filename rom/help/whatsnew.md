New Features in CraftOS-PC v2.7.4:

* **Fixed critical crashing issue on Windows systems relating to ropes**
* Updated CC:T version to 1.104.0
  * The shell now supports hashbangs (`#!`) (emmachase).
  * Error messages in edit are now displayed in red on advanced computers.
  * Improvements to the display of errors in the shell and REPL.
  * Fix `rednet` queueing the wrong message when sending a message to the current computer.
  * Fix the Lua VM crashing when a `__len` metamethod yields.
  * `table` methods and `ipairs` now use metamethods.
  * Argument errors now follow the standard "X expected, got Y" format.
  * Add `coroutine.isyieldable`.
  * Type errors now use the `__name` metatag.
  * `xpcall` now accepts arguments after the error function.
  * `speaker` program now reports an error on common unsupported audio formats.
  * multishell now hides the implementation details of its terminal redirect from programs.
  * `settings.load` now ignores malformed values created by editing the .settings file by hand.
  * Ignore metatables in `textutils.serialize`.
  * Fix `gps.locate` returning `nan` when receiving a duplicate location (Wojbie).
* Added plugin support on iOS through in-app purchases
  * Use the `plugins` program to buy new plugin packs
  * Only one is available at the moment, featuring `ccemux`, `joystick`, and `sound`
* Native `load` now uses Lua 5.2 syntax, matching Cobalt's behavior
* Fixed crashing when calling `monitor.blit` when the cursor is off-screen
* Fixed compilation error on newer Linux systems

Type "help changelog" to see the full version history.
