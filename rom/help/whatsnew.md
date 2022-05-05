New Features in CraftOS-PC v2.6.6:

* Bumped CC:T version to 1.100.5
* Enabled proper HTTPS certificate verification
* Added support for URLs to `cc.http.gist`/`gist` program
* Added `seek` method to binary HTTP handles
* Added strip option to `string.dump` from Lua 5.3
* Fixed `paintutils.drawBox` not working properly in graphics mode
* Improved DFPWM audio quality
* Small compatibility fixes to drives
* Fixed type of `http_max_websocket_message` config setting
* Fixed crash when passing negative values to `monitor.scroll` (#244)
* Fixed crash in `string.rep` when allocation fails (crash report)
* Fixed possible race condition in WebSockets (crash report)
* Fixed a crash when `http_response_handle.write` throws an error (crash report)
* Fixed a possible crash when a rogue event is sent (crash report)
* Fixed a crash when an event is sent to a computer that was just destroyed (crash report)
* Fixed a possible crash when the abort timer triggers right as the computer shuts down (crash report)

Type "help changelog" to see the full version history.
