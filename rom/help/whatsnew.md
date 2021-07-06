New Features in CraftOS-PC v2.5.5:

* Disabled locks when modems aren't attached
  * This can improve speeds by up to 50%
  * If any modem is attached, speeds will drop back to pre-v2.5.5 levels
* Rewrote HTTP handle read functions to improve reliability
* Removed Origin header from WebSocket requests
* Fixed behavior of table length to work more like CC:T
* Fixed paste contents not being cut at the first newline
* Fixed memory leak in file.readAll in binary mode
* Fixed incorrect modulo result when {(a < 0 | b < 0) & |a| % |b| = 0}
* Fixed hard crash on startup when a custom font file doesn't exist
* Fixed crash when passing non-string in header table
* Fixed crash when halting computer after it already closed
* Fixed crash when an exception occurs while closing WebSocket in the middle of catching another exception
* Possibly fixed a crash happening when connecting to a WebSocket
* Readded Lua features that were advertised in v2.5.4 but not actually present on Windows
  * Added `debug.upvalue{id,join}` from Lua 5.3
  * Fixed a race conditions with modems causing a crash
  * Fixed some random crashes on an odd memory error
  * Fixed crash when passing bad argument #1 to `table.foreach`

Type "help changelog" to see the full version history.
