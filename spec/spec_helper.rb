require 'bundler/setup'
require 'simplecov'

SimpleCov.start do
  add_filter %r{/spec/}
end

require 'rspec'
require 'screen-recorder'
require 'watir'
require 'webdrivers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  #
  # Print error from ffmpeg log on test failure
  #
  config.after do |example|
    if example.exception
      # Print error from ffmpeg.log
      log_file = `ls | grep *.log`.strip
      if log_file
        f = File.open(log_file).readlines.last(10).join('\n')
        puts "FFMPEG error: #{f}"
        f.close
      end
    end
  end
end

#
# Returns input value for tests to use based on current OS.
#
def test_input
  if OS.linux?
    `echo $DISPLAY`.strip || ':0' # If $DISPLAY is not set, use default of :0.0
  elsif OS.mac?
    ENV['TRAVIS'] ? '0' : '1'
  elsif OS.windows?
    'desktop'
  else
    raise NotImplementedError, 'Your OS is not supported.'
  end
end

#
# Returns test output filename.
#
def test_output
  'recording.mkv'
end

#
# Returns test log filename.
#
def test_log_file
  'screen-recorder.log'
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
    log: test_log_file
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
# Returns capture device based on the current OS.
#
def test_capture_device
  return 'gdigrab' if OS.windows?

  return 'x11grab' if OS.linux?

  'avfoundation' if OS.mac?
end

#
# Deletes given file as part of cleanup.
#
def delete_file(file)
  FileUtils.rm file if File.exist? file
end