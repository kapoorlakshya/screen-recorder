require 'bundler/setup'
require 'simplecov'
SimpleCov.start

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

  config.after(:each) do |example|
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

def os_specific_input
  if OS.linux?
    `echo $DISPLAY`.strip || ':0.0' # If $DISPLAY is not set, use default of :0.0
  elsif OS.mac?
    ENV['TRAVIS'] ? '0' : '1'
  elsif OS.windows?
    'desktop'
  else
    raise NotImplementedError, 'Your OS is not supported.'
  end
end
