# FFMPEG::Screenrecorder

[![Gem Version](https://badge.fury.io/rb/ffmpeg-screenrecorder.svg)](https://badge.fury.io/rb/ffmpeg-screenrecorder)

Ruby gem to record your computer screen - desktop or specific application/window - using [FFmpeg](https://www.ffmpeg.org/).

## Windows Only

Only supports Windows as of version `1.0.0-beta3`. Linux and macOS support will be added before the final release of `v1.0.0`.

## Installation

[Download](https://www.ffmpeg.org/download.html), extract and add the location of `ffmpeg.exe` to your ENV `PATH` variable. Make sure you can execute ffmpeg:

    C:\Users\Lakshya Kapoor>ffmpeg -version
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

Add this line to your application's Gemfile:

```ruby
gem 'ffmpeg-screenrecorder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffmpeg-screenrecorder

## Usage

##### Record Desktop

```
opts               = { output:        'ffmpeg-screenrecorder-output.mp4',
                       input:         'desktop',
                       framerate:     30.0,
                       device:        'gdigrab',
                       log:           'ffmpeg-screenrecorder-log.txt' }
@recorder = FFMPEG::Screenrecorder.new(opts)

# Start recording
@recorder.start

# ... Run tests or whatever you want to record

# Stop recording
@recorder.stop

# Recording file will be available: ffmpeg-screenrecorder-output.mp4
```

##### Record Specific Application/Window
```
require 'watir'

browser = Watir::Browser.new :firefox

FFMPEG::Screenrecorder.window_titles('firefox') # Name of exe
#=> "Mozilla Firefox"

opts      = { output:    'ffmpeg-screenrecorder-firefox.mp4',
              input:     'Mozilla Firefox',
              framerate: 30.0,
              device:    'gdigrab',
              log:       'ffmpeg-screenrecorder-firefox.txt' }
@recorder = FFMPEG::Screenrecorder.new(opts)

# Start recording
@recorder.start

# ... Run tests or whatever you want to record

# Stop recording
@recorder.stop

browser.quit 
```

<b>Note</b>:
1. Always stop the recording before closing the application. Otherwise, ffmpeg will not exit gracefully and may produce an invalid video file.
2. If you're launching multiple applications or testing an application at different window sizes, recording the `desktop` is a better option.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kapoorlakshya/ffmpeg-screenrecorder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
