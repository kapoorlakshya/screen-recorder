require 'bundler/setup'
require 'simplecov'
require_relative '../lib/screen-recorder/os'

SimpleCov.start do
  add_filter %r{/spec/}
end

require 'rspec'
require 'screen-recorder'
require 'watir'
require 'pry-byebug' unless RUBY_PLATFORM == 'java'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    # Establish clean state
    delete_file '*.mkv'
    delete_file '*.png'
    delete_file '*.log'

    # Start xvfb if not running on Linux
    if ScreenRecorder::OS.linux?
      running = `pgrep Xvfb`.strip
      `Xvfb -ac ":0" -screen 0 1024x768x24 > /dev/null 2>&1 &` unless running
    end
  end

  config.after(:suite) do
    if ScreenRecorder::OS.linux? || ScreenRecorder::OS.mac?
      # check for any unexpectedly abandoned ffmpeg processes
      sleep(2) # wait any straglers to terminate
      running = `pgrep -f ffmpeg`.strip
      unless running.empty?
        `pkill -9 -f ffmpeg`
        raise 'Abandoned ffmpeg processes found! Killed, but please investigate.'
      end
    end
  end

  # Print error from ffmpeg log on test failure
  config.after do |example|
    if example.exception
      # Print error from ffmpeg log
      next unless File.exist?(test_log_file)

      File.open(test_log_file).readlines.last(10).join('\n') { puts "FFMPEG error: #{f}" }
    end
  end
end

#
# Returns input value for tests to use based on current ScreenRecorder::OS.
#
def test_input
  if ScreenRecorder::OS.linux?
    ENV.fetch('DISPLAY', ':0').strip
  elsif ScreenRecorder::OS.mac?
    ENV['CI'] ? '0' : '1'
  elsif ScreenRecorder::OS.windows?
    'desktop'
  else
    raise 'Your OS is not supported. Feel free to create an Issue on GitHub.'
  end
end

#
# Returns test output filename.
#
def test_output
  file = "recording-#{Time.now.to_i}.mkv"
  path = File.join(Dir.pwd, file)
  return path.tr('/', '\\') if ScreenRecorder::OS.windows?

  path
end

#
# Returns test log filename.
#
def test_log_file
  file = 'ffmpeg.log'
  path = File.join(Dir.pwd, file)
  return path.tr('/', '\\') if ScreenRecorder::OS.windows?

  path
end

#
# Returns Hash of advanced parameters for the tests to use.
#
def test_advanced
  {
    input:    {
      video_size:  '640x480',
      show_region: '1'
    },
    output:   {
      framerate: 30.0
    },
    loglevel: 'level+debug', # For FFmpeg
    log:      test_log_file
  }
end

#
# Returns test options for ScreenRecorder::Options to use.
#
def test_options
  { input:     test_input,
    output:    test_output,
    log_level: Logger::INFO,
    advanced:  test_advanced }
end

#
# Returns capture device based on the current ScreenRecorder::OS.
#
def test_capture_device
  return 'gdigrab' if ScreenRecorder::OS.windows?

  return 'x11grab' if ScreenRecorder::OS.linux?

  'avfoundation' if ScreenRecorder::OS.mac?
end

#
# Deletes files with given naming pattern.
#
def delete_file(pattern)
  Dir.glob("#{Dir.pwd}/#{pattern}").each { |f| File.delete(f) }
end

#
# Returns resolution of the given video/image file.
#
def get_resolution(filename)
  metadata = FFMPEG::Movie.new(filename)
  metadata.resolution
end
