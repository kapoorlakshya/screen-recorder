# ScreenRecorder

[![Gem Version](https://badge.fury.io/rb/screen-recorder.svg)](https://badge.fury.io/rb/screen-recorder)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/gems/screen-recorder/)
[![Tests](https://github.com/kapoorlakshya/screen-recorder/actions/workflows/tests.yml/badge.svg)](https://github.com/kapoorlakshya/screen-recorder/actions/workflows/tests.yml)

A Ruby gem to video record or take screenshots of your computer screen - desktop or specific
window - using [FFmpeg](https://www.ffmpeg.org/). Primarily
geared towards recording automated UI (Selenium) test executions for
debugging and documentation.

#### Demo

[https://kapoorlakshya.github.io/introducing-screen-recorder-ruby-gem](https://kapoorlakshya.github.io/introducing-screen-recorder-ruby-gem)

## Compatibility

Works on Windows, Linux, and macOS. Requires Ruby 2.0+ or JRuby 9.2+.

## Installation

##### 1. Setup FFmpeg

Download from [here](https://ffmpeg.org/download.html) and add to `PATH` or use `brew` / `winget` / `apt` to install.

> macOS: Follow [these steps](https://github.com/kapoorlakshya/screen-recorder/issues/88#issuecomment-629139032) to avoid
> issues related to Privacy settings.

Alternatively, you can point to the binary file using `ScreenRecorder.ffmpeg_binary = '/path/to/ffmpeg'` in your project.

##### 2. Install gem

Next, add these lines to your application's Gemfile:

```ruby
gem 'screen-recorder', '~> 1.0'
```

And then execute:

```bash
bundle install
```

##### 3. Require gem

```ruby
require 'screen-recorder'
```

## Usage

#### Record Desktop

```ruby
@recorder = ScreenRecorder::Desktop.new(output: 'recording.mkv')
@recorder.start

# Run tests or whatever you want to record

@recorder.stop
```

Linux and macOS users can optionally provide a display or input device number.
Read more about it in the wiki [here](https://github.com/kapoorlakshya/screen-recorder/wiki/Display-or-Input-Device-Selection).

#### Record Application Window (Microsoft Windows only)

```ruby
require 'watir'

browser   = Watir::Browser.new :firefox
@recorder = ScreenRecorder::Window.new(title: 'Mozilla Firefox', output: 'recording.mkv')
@recorder.start

# Run tests or whatever you want to record

@recorder.stop
browser.quit 
```

This mode has a few limitations which are listed in the wiki
[here](https://github.com/kapoorlakshya/screen-recorder/wiki/Window-Capture-Limitations).

##### Fetch Title

A helper method is available to fetch the title of the active window
for the given process name.

```ruby
ScreenRecorder::Window.fetch_title('firefox') # Name of exe
#=> ["Mozilla Firefox"]

ScreenRecorder::Window.fetch_title('chrome')
#=> ["New Tab - Google Chrome"]
```

#### Capture Audio

Provide the following `advanced` configurations to capture audio:

```ruby
# Linux
advanced = { f: 'alsa', ac: 2, i: 'hw:0'} # Using ALSA
# Or using PulseAudio 
advanced = { 'f': 'pulse', 'ac': 2, 'i': 'default' } # Records default sound output device 

# macOS
advanced = { input: { i: '1:1' } } # -i video:audio input device ID

# Windows
advanced = { f: 'dshow', i: 'audio="Microphone (Realtek High Definition Audio)"' }
```

You can retrieve a list of audio devices by running these commands:

```
# Linux
$ arecord -L # See https://trac.ffmpeg.org/wiki/Capture/ALSA

# macOS
$ ffmpeg -f avfoundation -list_devices true -i ""

# Windows
> ffmpeg -list_devices true -f dshow -i dummy
```

#### Screenshots

Screenshots can be captured at any point after initializing the recorder:

```ruby
# Desktop
@recorder = ScreenRecorder::Desktop.new(output: 'recording.mkv')
@recorder.screenshot('before-recording.png')
@recorder.start
@recorder.screenshot('during-recording.png')
@recorder.stop
@recorder.screenshot('after-recording.png')

# Window (Microsoft Windows only)
browser   = Watir::Browser.new :chrome, options: { args: ['--disable-gpu'] } # Hardware acceleration must be disabled
browser.goto('watir.com')
window_title = ScreenRecorder::('chrome').first
@recorder = ScreenRecorder::Window.new(title: window_title, output: 'recording.mkv')
@recorder.screenshot('before-recording.png')
@recorder.start
@recorder.screenshot('during-recording.png')
@recorder.stop
@recorder.screenshot('after-recording.png')
browser.quit 
```

You can even specify a custom capture resolution:

```rb
@recorder.screenshot('screenshot.png', '1024x768')
```

#### Video Output

Once the recorder is stopped, you can view the video metadata or transcode
it if desired.

```ruby
@recorder.video
=> #<FFMPEG::Movie:0x0000000004327900 
        @path="recording.mkv", 
        @metadata={:streams=>[{:index=>0, :codec_name=>"h264", :codec_long_name=>"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10", 
        :profile=>"High", 
        :codec_type=>"video"} 
        @video_codec="h264", 
        @colorspace="yuv420p", 
        ... >

@recorder.video.transcode("recording.mp4") { |progress| puts progress } # 0.2 ... 0.5 ... 1.0
```

See [`streamio-ffmpeg`](https://github.com/streamio/streamio-ffmpeg) gem for more details.

#### Discard Recording

If your test passes or you do not want the recording for any reason,
simply call `@recorder.discard` or `@recorder.delete` to delete
the video file.

#### Advanced Options

You can provide additional parameters to FFmpeg using the `advanced`
parameter. You can specify input/output specific parameters using `input: {}`
and `output: {}` within the `advanced` Hash.

```ruby
advanced = {
  input:    {
    framerate:  30,
    pix_fmt:    'yuv420p',
    video_size: '1280x720'
  },
  output:   {
    r:       15, # Framerate
    pix_fmt: 'yuv420p'
  },
  log:      'recorder.log',
  loglevel: 'level+debug', # For FFmpeg
}
ScreenRecorder::Desktop.new(output: 'recording.mkv', advanced: advanced)
```

This will be parsed as:

```bash
ffmpeg -y -f gdigrab -framerate 30 -pix_fmt yuv420p -video_size 1280x720 -i desktop -r 15 pix_fmt yuv420p -loglevel level+debug recording.mkv
```

#### Logging & Debugging

You can configure the logging level of the gem to troubleshoot problems:

```ruby
ScreenRecorder.logger.level = :DEBUG
```

Also refer to the `ffmpeg.log` file for details.

#### Use with Cucumber

A Cucumber + Watir based example is available
[here](https://github.com/kapoorlakshya/cucumber-watir-test-recorder-example).

## Wiki

Please see the [wiki](https://github.com/kapoorlakshya/screen-recorder/wiki) for solutions to commonly reported issues.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `bundle exec rake` to run the tests and rubocop. You can also run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Contributing

Bug reports and pull requests are welcome.

- Please update the specs for your code changes and run them locally with `bundle exec rake spec`.
- Follow the Ruby style guide and format your code - <https://github.com/rubocop-hq/ruby-style-guide>

### License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Thanks to [Denys Bazarnyi](https://github.com/bazarnyi) for testing
macOS compatibility in v1.1.0.
<br />
<br />

[![Streamio](http://d253c4ja9jigvu.cloudfront.net/assets/small-logo.png)](http://streamio.com)

This gem relies on the [streamio-ffmpeg](https://github.com/streamio/streamio-ffmpeg)
gem to extract metadata from the output file.
<br />
<br />
