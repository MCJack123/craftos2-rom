New Features in CraftOS-PC v2.6.4:

* Updated CC:T version to 1.100.0
  * Speakers can now play arbitrary PCM audio.
  * Add support for encoding and decoding DFPWM streams, with the cc.audio.dfpwm module.
  * Fix the "repeat" program not repeating broadcast rednet messages.
* Added `useDFPWM` config setting to toggle use of DFPWM playback emulation
* Added `speaker.setPosition(x, y, z)` to emulate positioning of speaker audio
* Standards mode now controls the behavior of the new `speaker.playAudio`
  * When disabled, all audio is added to a queue with no latency, and `speaker.playAudio` never fails
  * When enabled:
    * `speaker_audio_empty` is queued when the audio is 0.5 seconds before it's expected to finish, emulating latency
    * `speaker.playAudio` returns `false` if there is more than 0.5 seconds of audio in the buffer
    * `useDFPWM` is forced to `true`
* Renamed `speaker.stopSounds` to `speaker.stop`
  * `stopSounds` still exists for backwards compatibility, but is deprecated
* `speaker.playLocalMusic` is now deprecated in favor of `speaker.playAudio`
  * It is recommended you load the audio files yourself instead of relying on the system to decode it
* CraftOS-PC Online is now working better (#222)
  * CraftOS-PC Online now supports Safari on iOS 15.2+/macOS 12.2+
  * There is currently a huge memory leak bug in some browsers that can cause the page to crash on low-memory systems
  * Hopefully CraftOS-PC Online will be fully working in the near future
* Fixed some string comparisons not working as expected
* Fixed incorrect documentation on mobile gestures (#230)
* Fixed keyboard on iOS being dismissed when closing the app (#231)
* Fixed screen glitches when opening a new terminal after changing `useHDFont` (SkyTheCodeMaster)
* Fixed some issues with textutils.serializeJSON

Type "help changelog" to see the full version history.
