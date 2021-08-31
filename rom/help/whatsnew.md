New Features in CraftOS-PC v2.6.1:

* Bumped CC:T version to 1.98.2
  * Add motd for file uploading.
  * Fix `settings.define` not accepting a nil second argument (SkyTheCodeMaster).
  * Add a missing type check for `http.checkURL`.
  * Prevent `parallel.*` from hanging when no arguments are given.
  * Prevent issue in rednet when the message ID is NaN.
  * Fix `help` program crashing when terminal changes width.
  * Prevent `wget` crashing when given an invalid URL and no filename.
  * Correctly wrap string within `textutils.slowWrite`.
* Bumped structure version to 5
  * New fields in `configuration`:
    * `useWebP`
  * New fields in `Computer`:
    * `httpRequestQueue`
    * `httpRequestQueueMutex`
* Added support for screenshots and recordings in WebP format
  * WebP is an image format that is much smaller than PNG/GIF and supports animation
  * All modern web browsers and OSes support WebP images
    * Unfortunately, Discord does not support WebP recordings at the moment.
  * Recordings can be up to 20x smaller than their GIF counterparts
  * Disabled by default; enable the `useWebP` config option to use WebP instead of PNG/GIF
* Added support for delta installers on Windows
  * These are stripped-down versions of the installer that only contain core CraftOS-PC files
  * This reduces the size of data to download when updating
  * Some versions may not have delta installers if libraries need to be updated
* Added update download progress window on Windows; made progress bar determinate on macOS
* Implemented limits for HTTP options that were present but unfunctional
* Parameters to events are now copied when standards mode is enabled
* Opening a file when the maximum file count is reached now creates the file as expected
* Rewrote `websocket.receive` function in C to perform better
* Fixed WebSockets not sending PONG packets, causing sockets to randomly close after a while
* Fixed crashes when trying to use a WebSocket handle after closing it
* Fixed a race condition in HTTP requests that caused a crash
* Fixed a race condition causing crashes when running a task on the main thread
* Fixed a race condition causing functions (like `term.write`) to be run on the wrong computer
* Fixed an issue causing the first frame of GIFs to be darker than the rest of the recording
* Fixed the close button not working in some cases
* Fixed `fs` API allowing illegal characters on Windows
* Fixed modems not checking if channel numbers are in range
* Fixed `utf8.charpattern` not existing
* Fixed crash error message not appearing in standards mode
* Fixed `os.clock()` not resetting on reboot (#215)
* Fixed crash reporter failing to upload files + some websites failing to connect
  * TLS 1.3 was disabled (pocoproject/poco#3395), so HTTPS connections may be slightly less secure
* Fixed duplication of default black/whitelist entries
* Fixed `pairs` returning incorrect values after a call hook

Type "help changelog" to see the full version history.
