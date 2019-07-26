# Changelog

This project adheres to [Semantic Versioning](https://semver.org/).

### 1.3.0 (2019-07-26)
* Support JRuby 9.2+ ([#58](https://github.com/kapoorlakshya/screen-recorder/issues/58))
* Add `ScreenRecorder::Window.fetch_title` as an alias for `ScreenRecorder::Titles.fetch`.
The `Titles` class will be removed in version 2.0.

### 1.2.0 (2019-05-12)
* Separate input/output specific `ffmpeg` arguments through the `advanced` 
Hash. See example [here](https://github.com/kapoorlakshya/screen-recorder#advanced-options).
* Check for errors after starting the `ffmpeg` process to make sure the 
recording does not stop silently because of an error. Prints the error 
from the log if the process exists unexpectedly.
* Now using [`childprocess`](https://github.com/enkessler/childprocess) gem
to manage the `ffmpeg` process. This requires the  `ffi` gem to be 
installed on Windows. See [childprocess#132](https://github.com/enkessler/childprocess/issues/150)
for more information.

### 1.1.0 (2019-04-14)
* <b>Add support for macOS</b> ([#55](https://github.com/kapoorlakshya/screen-recorder/issues/55)). 
Thanks to [Denys Bazarnyi](https://github.com/bazarnyi) for testing this and providing feedback.
* Force kill `ffmpeg` if it takes more than 10s to quit ([#60](https://github.com/kapoorlakshya/screen-recorder/issues/60)).
* Fix a bug where `ScreenRecorder.ffmpeg_binary=()` was not properly defined.
* `ScreenRecorder::Titles#fetch` will now raise `NotImplementedError` when used in a 
Linux or a macOS environment. Only works on Windows.
* Default `input` value on Linux is now `:0`.

### 1.0.0 (2019-03-15)
* Released first major version.
* Now uses `ScreenRecorder` as top level module. `FFMPEG` is not directly 
exposed anymore.
* The recording modes are now available through `ScreenRecorder::Desktop` 
and `ScreenRecorder::Window` classes to make the usage (parameters) simpler.
* Method parameters are now keywords instead of an `opts` Hash. This means
at least Ruby 2.0.0 is required.
* `framerate:` is now to be passed through the `advanced` Hash. 

### 1.0.0.beta13 (2019-03-15)
* Gem will now be renamed to `screen-recorder`. Please refer to Issue 
[#45](https://github.com/kapoorlakshya/screen-recorder/issues/45)
for more information.

### 1.0.0.beta12 (2019-03-12)
* Reverted post install message as `screen_recorder` is already taken.

### 1.0.0.beta11 (2019-03-12)
* Recording FPS (`framerate`) is defaulted to 15.0.
* Gem will soon be renamed to `screen_recorder`. Please refer to Issue 
[#45](https://github.com/kapoorlakshya/screen-recorder/issues/45)
for more information.

### 1.0.0.beta10 (2019-02-05)
* Fixed an edge case in Microsoft Windows specific implementation of
`WindowTitles#fetch` where processes with mismatching names and window
titles, such as process `"Calculator.exe"` with window title `"CicMarshalWnd"`,
were omitted ([#35](https://github.com/kapoorlakshya/screen-recorder/issues/35)).
This fix also prints a warning when this mismatch occurs.
* Fixed bug in Linux specific `WindowTitles#fetch` implementation where
the filter by application name logic was removed. This filter is required
on Linux here because `wmctrl` returns all open window titles unlike
Microsoft Windows where `taskmgr` allows us get window titles by process
name.
* On Linux, you are now required to provide the `input` as `"desktop"`
or a display number, such as `":0.0"`. Run `echo $DISPLAY` to check your display number.
* QOL improvements - Type checking of inputs, spec cleanup, added more
tests, and fixed rubocop warnings.

### 1.0.0.beta9 (2019-01-22)

* :warning: `FFMPEG::RecordingRegions` is now `FFMPEG::WindowTitles`, so the module name is true to the function it provides.
* Added support for for a user given path via `FFMPEG#ffmpeg_binary=()`.
* Removed Bundler version requirement from gemspec to support all versions.
* Implement `#discard` (alias `#delete`) to discard the video file. Useful when your test passes and you want to get rid of the video file.

### 1.0.0.beta8 (2019-01-03)

* Fix a bug where the gem was incorrectly configured to be required as `ffmpeg/screenrecorder` instead of `screen-recorder`.
* `ScreenRecorder#start` now returns the IO process object in case the user has a use case for it.
* `RecordingRegion#fetch` now logs a warning that `x11grab` for Linux does not supporting window recording.
* :warning: Parameter `infile` is now `input` to make it more intuitive.

### 1.0.0.beta7 (2018-12-23)

* Fix bug in RecorderOptions where an incorrect object was referenced to read the user provided options.

### 1.0.0.beta6 (2018-12-3)

* Stopping the screenrecorder now prints the failure reason given by the ffmpeg binary when `#stop` fails (Issue #7).
* Log file is now defaulted to `ffmpeg.log` instead of redirecting to nul.
* `log_level` now defaults to `Logger::ERROR` instead of `Logger::INFO`.

### 1.0.0.beta5 (2018-11-26)

* `Screenrecorder` class is now `ScreenRecorder`.
* Add support for Linux.
* Now an exception raised if the gem fails to find `ffmpeg`.
* Fix a bug where a file named `nul` was created instead of directing the output to `NUL`.
* Fix a bug where `RecordingRegions#window_titles` was not returning anything because of missing return keyword.