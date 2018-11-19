require 'streamio-ffmpeg'
require 'os'
require_relative 'recorder_errors'
require_relative 'recorder_options'
require_relative 'recording_regions'

module FFMPEG
  # @since 1.0.0-beta1
  class Screenrecorder
    extend RecordingRegions

    attr_reader :options, :video

    def initialize(options = {})
      @options = RecorderOptions.new(options)
      @video   = nil
      @process = nil
      initialize_logger(@options.log_level || Logger::ERROR)
    end

    #
    # Starts the recording
    #
    def start
      @video     = nil # New file
      start_time = Time.now
      @process   = start_ffmpeg
      elapsed    = Time.now - start_time
      FFMPEG.logger.debug "Process started in #{elapsed}s"
      FFMPEG.logger.info 'Recording...'
    end

    #
    # Stops the recording
    #
    def stop
      FFMPEG.logger.debug 'Stopping ffmpeg.exe...'
      elapsed = kill_ffmpeg
      FFMPEG.logger.debug "Stopped ffmpeg.exe in #{elapsed}s"
      FFMPEG.logger.info 'Recording complete.'
      @video = Movie.new(options.output)
    end

    private

    #
    # Launches the ffmpeg binary using a generated command based on
    # the given options.
    #
    def start_ffmpeg
      FFMPEG.logger.debug "Command: #{command}"
      process = IO.popen(command, 'r+')
      sleep(1.5) # Takes ~1.5s on average to initialize
      process
    end

    #
    # Sends 'q' to the ffmpeg binary to gracefully stop the process.
    #
    def kill_ffmpeg
      @process.puts 'q' # Gracefully exit ffmpeg
      elapsed = wait_for_io_eof(5)
      @process.close_write # Close IO
      elapsed
    end

    #
    # Initializes the logger with the given log level.
    #
    def initialize_logger(level)
      FFMPEG.logger.progname  = 'FFmpeg'
      FFMPEG.logger.level     = level
      FFMPEG.logger.formatter = proc do |severity, time, progname, msg|
        "#{time.strftime('%F %T')} #{progname} - #{severity} - #{msg}\n"
      end
      FFMPEG.logger.debug 'Logger initialized.'
    end

    #
    # Generates the command line arguments based on the given
    # options.
    #
    def command
      cmd = "#{FFMPEG.ffmpeg_binary} -y "
      cmd << @options.parsed
    end

    #
    # Waits for IO#eof? to return true
    # after 'q' is sent to the ffmpeg process.
    #
    def wait_for_io_eof(timeout)
      start = Time.now
      Timeout.timeout(timeout) do
        sleep(0.1) until @process.eof?
      end
      FFMPEG.logger.debug "IO#eof? #{@process.eof?}"
      Time.now - start
    end
  end # class Recorder
end # module FFMPEG
