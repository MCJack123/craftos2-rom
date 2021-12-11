New Features in CraftOS-PC v2.6.3:

* Updated CC:T version to 1.99.1
  * Peripherals can now have multiple types. `peripheral.getType` now returns multiple values, and `peripheral.hasType` checks if a peripheral has a specific type.
  * Add feature introduction/changed version information to the documentation. (MCJack123)
  * Rednet can now handle computer IDs larger than 65535. (Ale32bit)
  * Optimise peripheral calls in `rednet.run`. (xAnavrins)
  * Add `cc.pretty.pretty_print` helper function (Lupus590).
  * Fix `textutils.serialize` not serialising infinity and nan values. (Wojbie)
  * Add `package.searchpath` to the `cc.require` API. (MCJack123)
* Bumped structure version to 7
  * New fields in `Computer`:
    * `shouldDeleteDebugger`
  * New fields in `peripheral`:
    * `getTypes`
* Added ability to set printer ink color
* Added support for hexadecimal floating-point numbers
* Unwritable data directories now throw an error
* Default peripherals now throw an error when calling a method that doesn't exist
* Terminal frozen status is now reset after rebooting
* X11 and Wayland libraries are no longer required when building for Linux
* `\0` characters in a string are now treated as a space by `load`
* Fixed websocket.receive not functioning properly
* Fixed `fs.copy` stopping at EOF bytes on Windows (#226)
* Fixed hardware renderer not showing anything on screen (#227)
* Fixed crash when using `detach` on a debugger
* Fixed crash when an error occurs in `drive.insertDisk` on Windows
* Fixed coroutine metatable getting overwritten by coroutine.create
* Fixed `keepOpenOnShutdown` using 100% CPU
* Fixed Ctrl+R not working with `keepOpenOnShutdown` after two successive reboots
* Fixed `getCursorBlink` being missing from monitors
* Fixed monitor events not working properly in raw mode
* Fixed a possible race condition when shutting down on exit
* Fixed race condition in timer erasure
* Fixed various other small race conditions

Type "help changelog" to see the full version history.
