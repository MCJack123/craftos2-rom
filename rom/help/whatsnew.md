New Features in CraftOS-PC v2.8:

* Update CC:T version to 1.109.2
  * Update to Lua 5.2
    * `getfenv`/`setfenv` now only work on Lua functions.
    * Add support for `goto`.
    * Remove support for dumping and loading binary chunks.
      * Only disabled in standards mode
  * File handles, HTTP requests and websocket messages now use raw bytes rather than converting to UTF-8.
  * `fs.open` now supports `r+`/`w+` modes.
  * Add `allow_repetitions` option to `textutils.serialiseJSON`.
  * `math.random` now uses Lua 5.4's random number generator.
  * `tostring` now correctly obeys `__name`.
* Rewrote WebSocket server API (#337)
  * Use `server = http.websocketServer(port)` to create a server handle
  * `server.listen()` waits for a new connection, and returns a new WebSocket handle
    * Handles have an additional `clientID` field for identifying the client connection
  * `server.close()` closes the server
  * Events are now under the `websocket_server_` domain
    * `websocket_server_connect <port> <handle>`: Sent when a client connects to the server
    * `websocket_server_message <clientID> <message> <binary>`: Sent when a client sends a message
    * `websocket_server_closed <clientID> [closeCode] [closeMessage]`: Sent when a client disconnects from the server
* Bumped plugin *major* version to 12
  * Lua 5.2 breaks old plugins - please reinstall/rebuild any plugins (ccemux is updated)
* WebSocket close events now send the close code if available
* Fixed WebSocket ping messages causing the socket to close
* Fixed many memory corruption issues around ropes
* Fixed some issues with debug hooks and yielding
* Fixed crash when erroring from a debug hook (#326)
* Debuggers now inherit the mount list from the original computer (#327)
* Fixed memory reporting when using `string.rep` (#328)
* Fixed `fs.getFreeSpace` not checking parent directories if the path doesn't exist (#330)
* Fixed crash when using HTTP in the VS Code extension (#332)
* Fixed repeated `websocket.close` calls causing a crash (#336)
* Mobile: Added onboarding screen for navigation bar instructions

Type "help changelog" to see the full version history.
