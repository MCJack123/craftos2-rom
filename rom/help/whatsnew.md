New Features in CraftOS-PC v2.8.2:

* Updated CC:T version to 1.110.2
  * Discard characters being typed into the editor when closing `edit`'s `Run` screen.
  * Improve several Lua parser error messages.
  * `colour.toBlit` correctly errors on out-of-bounds values.
  * Round non-standard colours in `window`, like `term.native()` does.
  * Fix `speaker` program not resolving files relative to the current directory.
  * Add `speaker sound` command (fatboychummy).
  * Improve error when calling `speaker play` with no path (fatboychummy).
  * Prevent playing music discs with `speaker.playSound`.
  * Various documentation fixes (cyberbit).
* Fix compilation on Linux with MUSL libc (Ocawesome101, #341)
* Fixed Homebrew Cask release action
* Added log message for queue overflows
* Fixed some argument parsing issues in `http.request`
* Fixed some issues with timers
* Fix string comparison errors (migeyel, MCJack123/craftos2-lua#6)
* Fixed an inconsistency with Cobalt with `table.remove`
* lua_Unsigned uses 64-bit ints again, fixing many bugs (MCJack123/craftos2-lua#7)
* Fixed crash when trying to halt computer
* Fixed race condition in debug adapter
* Fixed some missing `os.date` specifiers on Windows
* Fix for "Port already in use" error when trying to reopen WebSocket server on the same port. (simadude, #343)
* Fixed seeking not working on HTTP handles in standards mode only
* Chest Inventory peripheral list returns entries for empty slots (NuclearMonk, #340)
* Fixed drives not emitting `disk` events
* Fixed issue in inventories when `toSlot` isn't provided
* Added warning message when the configuration file can't be saved
* Fixed `speaker_audio_empty` not firing on `speaker.stop`

Type "help changelog" to see the full version history.
