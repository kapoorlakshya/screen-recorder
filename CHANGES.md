### 1.0.0.beta10 (2019-02-05)
* Fixed an edge case in Microsoft Windows specific implementation of
`WindowTitles#fetch` where processes with mismatching names and window
titles, such as process `"Calculator.exe"` with window title `"CicMarshalWnd"`,
were omitted ([#35](https://github.com/kapoorlakshya/ffmpeg-screenrecorder/issues/35)).
This fix also prints a warning when this mismatch occurs.
* The fix for #35 introduces a mild inconvenience when using
applications like Chrome, which spawn a new process per window or
extension. `#fetch` now returns titles for these additional processes
with the visible window (web page) title. In a future release, you will
be able to use something like `full_match: true` to prevent this.
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

* Fix a bug where the gem was incorrectly configured to be required as `ffmpeg/screenrecorder` instead of `ffmpeg-screenrecorder`.
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