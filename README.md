# FFMPEG::ScreenRecorder

[![Gem Version](https://badge.fury.io/rb/ffmpeg-screenrecorder.svg)](https://badge.fury.io/rb/ffmpeg-screenrecorder)
![https://rubygems.org/gems/ffmpeg-screenrecorder](https://ruby-gem-downloads-badge.herokuapp.com/ffmpeg-screenrecorder?type=total)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](https://www.rubydoc.info/github/kapoorlakshya/ffmpeg-screenrecorder/master)

Ruby gem to record your computer screen - desktop or specific application/window - using [FFmpeg](https://www.ffmpeg.org/).

## Compatibility

Supports Windows and Linux as of version `1.0.0-beta5`. macOS support will be added before the final release of `v1.0.0`.

## Installation

On Microsoft Windows, [download](https://www.ffmpeg.org/download.html#build-windows), extract and add the location of `/bin` to your ENV `PATH` variable. 

For Linux, follow instructions here - https://ffmpeg.org/download.html#build-linux

Once installed, make sure ffmpeg is found:

    $ ffmpeg -version
    ffmpeg version N-92132-g0a41a8bf29 Copyright (c) 2000-2018 the FFmpeg developers
    built with gcc 8.2.1 (GCC) 20180813
    configuration: --enable-gpl --enable-version3 --enable-sdl2 --enable-fontconfig --enable-g
    nutls --enable-iconv --enable-libass --enable-libbluray --enable-libfreetype --enable-libm
    p3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopenjpeg --enable
    -libopus --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libtheora --enable
    -libtwolame --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libx264 --enable
    -libx265 --enable-libxml2 --enable-libzimg --enable-lzma --enable-zlib --enable-gmp --enab
    le-libvidstab --enable-libvorbis --enable-libvo-amrwbenc --enable-libmysofa --enable-libsp
    eex --enable-libxvid --enable-libaom --enable-libmfx --enable-amf --enable-ffnvcodec --ena
    ble-cuvid --enable-d3d11va --enable-nvenc --enable-nvdec --enable-dxva2 --enable-avisynth
    libavutil      56. 19.101 / 56. 19.101
    libavcodec     58. 32.100 / 58. 32.100
    libavformat    58. 18.104 / 58. 18.104
    libavdevice    58.  4.105 / 58.  4.105
    libavfilter     7. 33.100 /  7. 33.100
    libswscale      5.  2.100 /  5.  2.100
    libswresample   3.  2.100 /  3.  2.100
    libpostproc    55.  2.100 / 55.  2.100

Next, add this line to your application's Gemfile:

```ruby
gem 'ffmpeg-screenrecorder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffmpeg-screenrecorder

## Usage

#### Required Options

- `:input` - `'desktop'` or application window name
- `:output` - Output file location/name
- `:framerate` - Capture FPS

#### Advanced Options

- `:log`  - Defaults to `ffmpeg.log`
- `:log_level` for this gem

All other FFmpeg options can be passed through the `advanced` key. This feature is yet to be fully tested, so please feel free to report any bugs or request a feature.

```
opts = { input:     'desktop',
         output:    'recorder-test.mp4',
         framerate: 15,
         log:       'recorder.log',
         log_level: Logger::DEBUG, # For gem
         advanced: { loglevel: 'level+debug', # For FFmpeg
                     video_size:  '640x480',
                     show_region: '1' }
}
```

##### Record Desktop

```
opts      = { input:     'desktop',
              output:    'screenrecorder-desktop.mp4',
              framerate: 15.0 }
@recorder = FFMPEG::ScreenRecorder.new(opts)

# Start recording
@recorder.start #=> #<IO:fd 5>

# ... Run tests or whatever you want to record

# Stop recording
@recorder.stop #=> #<FFMPEG::Movie...>

# Recorded file
@recorder.video #=> #<FFMPEG::Movie...>
```

##### Record Application Window - Microsoft Windows (`gdigrab`) Only
```
require 'watir'

browser = Watir::Browser.new :firefox

FFMPEG::RecordingRegions.fetch('firefox') # Name of exe
#=> ["Mozilla Firefox"]

opts      = { input:     FFMPEG::RecordingRegions.fetch('firefox').first,
              output:    'screenrecorder-firefox.mp4',
              framerate: 15.0,
              log:       'screenrecorder-firefox.log' }
@recorder = FFMPEG::ScreenRecorder.new(opts)

# Start recording
@recorder.start

# Run tests or whatever you want to record
browser.goto 'watir.com'
browser.link(text: 'News').wait_until_present.click

# Stop recording
@recorder.stop

browser.quit 
```

<b>Note</b>:
- Always stop the recording before closing the application. Otherwise, ffmpeg will force exit as soon as the window disappears and may produce an invalid video file.
- If you're launching multiple applications or testing an application at different window sizes, recording the `desktop` is a better option.

## Demo

You can find example video recordings here - [https://kapoorlakshya.github.io/introducing-ffmpeg-screenrecorder](https://kapoorlakshya.github.io/introducing-ffmpeg-screenrecorder)

Cucumber + Watir based example - [kapoorlakshya/cucumber-watir-test-recorder-example](https://github.com/kapoorlakshya/cucumber-watir-test-recorder-example)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome. 

- Please update the specs for your code changes and run them locally with `bundle exec rake spec`.
- Follow the Ruby style guide and format your code - https://github.com/rubocop-hq/ruby-style-guide

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

![SauceLabs Logo](https://saucelabs.com/content/images/logo.png)

Thanks to [SauceLabs](https://saucelabs.com) for providing me with a free account. If you manage an open source project, you can apply for a free account [here](https://saucelabs.com/open-source).