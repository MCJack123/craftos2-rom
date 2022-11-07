New Features in CraftOS-PC v2.7.2:

* Updated CC:T version to 1.101.1
  * File drag-and-drop now queues a file_transfer event on the computer. The built-in shell or the import program must now be running to upload files.
  * The peripheral now searches for remote peripherals using any peripheral with the peripheral_hub type, not just wired modems.
  * Add include_hidden option to fs.complete, which can be used to prevent hidden files showing up in autocomplete results. (IvoLeal72)
  * Add shell.autocomplete_hidden setting. (IvoLeal72)
  * Prevent edit's "Run" command scrolling the terminal output on smaller screens.
  * Mention WAV support in speaker help (MCJack123).
  * Add http programs to the path, even when http is not enabled.
  * Fix example in textutils.pagedTabulate docs (IvoLeal72).
  * Fix help program treating the terminal one line longer than it was.
* Fixed a syntax error in the CCEmuX plugin's `emu` program (#271)
* Fixed a bug causing copies out of virtual mounts to fail (#272)
* Adjusted some behavior of ropes to hopefully make them faster & use less memory
  * Further fixes are in progress to fully optimize memory usage
* Fixed issues when reading from a bad file handle
* Fixed crashing when some filesystem functions fail
  * This was causing autocompletion on `config` to fail on Windows (#273), as well as crashing when using `fs.getSize` on a folder (#281)
* Fixed failure to launch on Apple Silicon Macs due to incorrectly named libraries (#287)
* Fixed missing `chest.getItemLimit` method (#291)
* Adjusted some logic in WebSocket handles to fix some potential issues
* Fixed window palettes being broken in graphics mode

Type "help changelog" to see the full version history.
