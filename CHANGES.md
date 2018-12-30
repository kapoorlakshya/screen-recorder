### 1.0.0.beta8 (TBD)

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