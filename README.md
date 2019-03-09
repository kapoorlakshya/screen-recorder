# FFmpeg ScreenRecorder

[![Gem Version](https://badge.fury.io/rb/ffmpeg-screenrecorder.svg)](https://badge.fury.io/rb/ffmpeg-screenrecorder)
![https://rubygems.org/gems/ffmpeg-screenrecorder](https://ruby-gem-downloads-badge.herokuapp.com/ffmpeg-screenrecorder?type=total)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/github/kapoorlakshya/ffmpeg-screenrecorder/master)
[![Build Status](https://travis-ci.org/kapoorlakshya/ffmpeg-screenrecorder.svg?branch=master)](https://travis-ci.org/kapoorlakshya/ffmpeg-screenrecorder)
[![Maintainability](https://api.codeclimate.com/v1/badges/a176dc755e06a23e5db8/maintainability)](https://codeclimate.com/github/kapoorlakshya/ffmpeg-screenrecorder/maintainability)

Ruby gem to record your computer screen - desktop or specific
window - using [FFmpeg](https://www.ffmpeg.org/). Primarily
geared towards recording automated UI test executions for easy
debugging and documentation.

## Demo

You can find example video recordings [here](https://kapoorlakshya.github.io/introducing-ffmpeg-screenrecorder).

## Compatibility

Supports Windows and Linux as of version `1.0.0-beta5`. macOS support will be added before the final release of `v1.0.0`.

## Installation

#### 1. Setup FFmpeg

Linux and macOS instructions are [here](https://www.ffmpeg.org/download.html). 

For Microsoft Windows, download the *libx264* enabled binary from [here](https://ffmpeg.zeranoe.com/builds/).
Once downloaded, add location of the `ffmpeg/bin` folder to `PATH` environment variable 
([instructions](https://windowsloop.com/install-ffmpeg-windows-10/)).

The gem also allows you to define the location using 
`ScreenRecorder.ffmpeg_binary = '/path/to/binary'` in your project.

#### 2. Install gem

Next, add this line to your application's Gemfile:

```ruby
gem 'ffmpeg-screenrecorder'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install ffmpeg-screenrecorder --pre
```

#### 3. Require gem

Require this gem in your project and start using the gem:

```ruby
require 'ffmpeg-screenrecorder'
```

## Record Desktop

```ruby
@recorder = ScreenRecorder::Desktop.new(output: 'recording.mp4')
@recorder.start

# ... Run tests or whatever you want to record

@recorder.stop
```

## Record Application Window

```ruby
require 'watir'

browser   = Watir::Browser.new :firefox
@recorder = ScreenRecorder::Window.new(title: 'Mozilla Firefox', output: 'recording.mp4')
@recorder.start

# Run tests or whatever you want to record

@recorder.stop
browser.quit 
```

<b>Fetch Title</b>

A helper method is available to fetch the title of the active window
from a visible application window (process name).

```ruby
ScreenRecorder::Titles.fetch('firefox') # Name of exe
#=> ["Mozilla Firefox"]
```

<b>Limitations</b>
- Only works on Microsoft Windows (gdigrab).
- `#fetch` only returns titles from currently active (visible) windows.
- `#fetch` may return `ArgumentError (invalid byte sequence in UTF-8)`
for a window title with non `UTF-8` characters.
See [#38](https://github.com/kapoorlakshya/ffmpeg-screenrecorder/issues/38)
for workaround.
- Always stop the recording before closing the application. Otherwise,
ffmpeg will force exit as soon as the window disappears and may produce
an invalid video file.
- If you're launching multiple applications or testing an application
at different window sizes, recording the `desktop` is a better option.

## Output

```ruby
@recorder.video
#=> #<FFMPEG::Movie:0x00000000067e0a08
    @path="recording.mp4",
    @container="mov,mp4,m4a,3gp,3g2,mj2",
    @duration=5.0,
    @time=0.0,
    @creation_time=nil,
    @bitrate=1051,
    @rotation=nil,
    @video_stream="h264 (High 4:4:4 Predictive) (avc1 / 0x31637661), yuv444p, 2560x1440, 1048 kb/s, 15 fps, 15 tbr, 15360 tbn, 30 tbc (default)",
    @audio_stream=nil,
    @video_codec="h264 (High 4:4:4 Predictive) (avc1 / 0x31637661)", @colorspace="yuv444p",
    @video_bitrate=1048,
    @resolution="2560x1440">
```

## Advanced Options

You can provide additional parameters to *ffmpeg* using the `advanced` 
parameter. This feature is yet to be fully tested, so please feel free 
to report any bugs or request a feature.

```ruby
  advanced = { framerate: 30,
               log:       'recorder.log',
               loglevel:  'level+debug', # For FFmpeg
               video_size:  '640x480',
               show_region: '1' }
  ScreenRecorder::Desktop.new(output:   'recording.mp4',
                              advanced: advanced)
```

This will be parsed as:

```bash
ffmpeg -y -f gdigrab -framerate 30 -loglevel level+debug -video_size 640x480 -show_region 1 -i desktop recording.mp4 2> recorder.log
```

## Logging

You can also configure the logging level of the gem:

```ruby
ScreenRecorder.logger.level = Logger::DEBUG
```

## Use with Cucumber

A Cucumber + Watir based example is available 
[here](https://github.com/kapoorlakshya/cucumber-watir-test-recorder-example).

## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Then, run `bundle exec rake spec` to run the tests. You can also run 
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome. 

- Please update the specs for your code changes and run them locally with `bundle exec rake spec`.
- Follow the Ruby style guide and format your code - https://github.com/rubocop-hq/ruby-style-guide

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

[![Streamio](http://d253c4ja9jigvu.cloudfront.net/assets/small-logo.png)](http://streamio.com)

This gem is based on the [streamio-ffmpeg](https://github.com/streamio/streamio-ffmpeg) gem.
<br />
<br />

![SauceLabs Logo](https://saucelabs.com/content/images/logo.png)

Thanks to [SauceLabs](https://saucelabs.com) for providing me with a 
free account. If you manage an open source project, you can apply for 
a free account [here](https://saucelabs.com/open-source).