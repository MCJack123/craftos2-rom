New Features in CraftOS-PC v2.6:

* CraftOS-PC is now available on Android and iOS
  * Apps are available on the iOS App Store (Play Store in the future; please download the APK manually)
  * Supports same feature set as desktop CraftOS-PC
    * Monitors and multi-computer support is missing, but will be added in a future version
  * Pinch in to open keyboard, out to close keyboard
  * Extra mobile-centric features:
    * `mobile` API with `openKeyboard(open: boolean)` and `isKeyboardOpen()` functions
    * `_CCPC_mobile_keyboard_open <height>` event when keyboard is opened, with an argument for visible height
    * `_CCPC_mobile_keyboard_close` event when keyboard is closed
* Bumped CC:T version to 1.97.0
  * 1.96.0:
    * Use lightGrey for folders within the "list" program.
    * Add cc.expect.range (Lupus590).
    * Allow calling cc.expect directly (MCJack123).
    * Fix paintutils.drawLine incorrectly sorting coordinates (lilyzeiset).
    * Correctly handle sparse arrays in cc.pretty.
  * 1.97.0:
    * Add scale subcommand to `monitor` program (MCJack123).
      * This is a modification of the already-existing `resolution` subcommand.
    * Add option to make `textutils.serialize` not write an indent (magiczocker10).
    * Allow comparing vectors using `==` (fatboychummy).
    * Allow `craft` program to craft unlimited items (fatboychummy).
    * Add program subcompletion to several programs (Wojbie).
    * Update the `help` program to accept and (partially) highlight markdown files.
    * Remove config option for the debug API.
      * It still exists internally, but is always set to `true`.
    * Allow uploading files by dropping them onto a computer.
    * Update the `wget` to be more resiliant in the face of user-errors.
    * Fix `exiting` paint typing "e" in the shell.
* Bumped structure version to 4
  * New fields in `PluginFunctions`:
    * `addEventHook`
    * `setDistanceProvider`
  * New fields in `Computer`:
    * `eventHooks`
    * Deprecated fields:
      * `nextMouseMove`
      * `lastMouse`
      * `mouseMoveDebounceTimer`
  * New fields in `Terminal`:
    * `nextMouseMove`
    * `lastMouse`
    * `mouseMoveDebounceTimer`
  * New types:
    * `event_hook`
* Upgraded raw mode protocol to version 1.1
  * New filesystem access ability
  * Computer windows now send the ID of the computer
  * Changed meaning of raw cursor blink field to indicate blinking, not showing
  * Small improvements to the protocol
  * Official protocol specification at https://www.craftos-pc.cc/docs/rawmode
* Improved performance of string concatenation by using ropes
  * Final concatenation of strings is not completed until the string's value needs to be read
  * This was implemented in CC:T 1.91.0
  * Expect repeated concatenation operations to be around 100x faster
* Improved performance of `string.sub` by using efficient substring views
  * Getting a substring no longer has to reallocate the string
  * Instead, it reuses the original string with the offset and length required
* Added HTTP whitelist & blacklist
  * Emulates configuration of CC:T up until 1.87.0 (before rule-based system)
* Added command-line option to connect to a remote WebSocket server in raw mode
* Changed cursor blink speed to 0.4s to match CC's behavior
* Rewrote main thread task queuer to be more efficient
* Setting `abortTimeout` to 0 now disables abort timeouts
* The close button no longer needs to be clicked twice to exit when `keepOpenOnShutdown` is enabled
* Fixed "400 Bad Request" error on HTTP requests when the path is empty
* Fixed crash when a bad URL is passed to HTTP functions
* Fixed an issue causing encoded slashes in URLs being decoded prematurely (#199)
* Fixed some memory leaks in HTTP handles
* Fixed HTTP not working properly in CraftOS-PC Online
* Fixed random crashes while sending messages over a modem (#205)
* Fixed sending recursive tables over modems
* Fixed old abort timer firing after reboot, causing spurious "Too long without yielding" errors
* Fixed crash when canceling a timer that doesn't exist
* Fixed `os.epoch "local"` not accounting for Daylight Savings Time
* Fixed files being truncated in text mode on Windows when a `\x0A` character is found (#204)
* Software rendering now reuses the same surface to reduce memory pressure
* Fixed an issue causing inconsistent speeds when recording to GIF
* Fixed blit only allowing gray colors on grayscale terminals
* Fixed monitors in raw mode sending close events to the wrong window ID
* Fixed some issues with setting monitor scale
* Fixed mouse event debouncing on monitors
* Fixed monitors not reporting a second `monitor_touch` event when clicked twice at the same point
* Fixed `mouse_move` leave event on monitors not sending the side
* Fixed a bug causing `mouse_move` events to stop being sent after a while
* Fixed behavior of `term.blit` when passing an invalid character to color strings
* Fixed raw client mouse events not being sent properly
* Fixed an issue causing crashes when creating certain peripherals
* Fixed a possible crash when the BIOS cannot be found (#208)
* `__lt` metamethods can now yield from inside `table.sort`
* Fixed a possible memory leak in `table.sort`
* Fixed an issue causing `__lt` metamethods that yield to return the wrong result from `<=`
* Fixed various errors in yielding from debug hooks
* Fixed stack not being resized when > 0x08000000 entries are required

Type "help changelog" to see the full version history.
