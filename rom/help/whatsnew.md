New Features in CraftOS-PC v2.6.5:

* Bumped CC:T version to 1.100.1
* Bumped structure version to 8
  * Functions are now pre-declared to ensure type compatibility
  * New macro `DLLEXPORT`
  * New class `TerminalFactory`
  * New fields in `configuration`:
    * `useDFPWM`
  * New fields in `PluginFunctions`:
    * `registerTerminalFactory`
    * `commandLineArgs`
    * `setListenerMode`
    * `pumpTaskQueue`
  * New fields in `Terminal`:
    * `factory`
* Fixed an issue causing an invalid string to be returned as the parameter for `speaker_audio_empty`
* `speaker.playAudio` now always returns `false` to tell programs to wait for `speaker_audio_empty` as expected
* Added caching to rope resolution to avoid concatenating the same rope multiple times
* Modified `string.rep` to work more like Cobalt
* Fixed hang when using CLI mode
* Fixed possible race condition in `mouse_move`
* Fixed an issue preventing the debugger console from scrolling
* Added an indicator showing whether the debugger console is no longer auto-scrolling
* Disabled loading of original `package` and `io` libraries to reduce possible vulnerabilities

Type "help changelog" to see the full version history.
