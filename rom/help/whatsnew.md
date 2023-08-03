New Features in CraftOS-PC v2.7.5:

* Updated CC:T version to 1.106.1
  * Optimise JSON string parsing.
  * Add `colors.fromBlit` (Erb3).
  * Add custom timeout support to the HTTP API.
  * The speaker program now errors when playing HTML files.
  * `edit` now shows an error message when editing read-only files.
  * Port `fs.find` to Lua. This also allows using `?` as a wildcard.
  * Add option to serialize Unicode strings to JSON (MCJack123).
  * Small optimisations to the `window` API.
  * Lua REPL no longer accepts `)(` as a valid expression.
  * Fix several inconsistencies with `require`/`package.path` in the Lua REPL (Wojbie).
* Added `term.relativeMouse` function, which converts `mouse_move` events into `mouse_move_relative` events with relative velocities
* Fixed `modem.getNameLocal` not existing
* Fixed abort timeouts firing after the computer goes into sleep mode
* Fixed stack corruption when using `string.format("%q")`
* Fixed a niche case crash when the computer turns off while prompting for abort timeout
* Fixed SSL errors in AppImage builds

Type "help changelog" to see the full version history.
