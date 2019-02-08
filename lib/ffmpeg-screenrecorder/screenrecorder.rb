require 'fileutils'
require_relative 'type_checker'
require_relative 'recorder_errors'
require_relative 'recorder_options'
require_relative 'window_titles'

module FFMPEG
  # @since 1.0.0-beta
  class ScreenRecorder
    attr_reader :options, :video

    def initialize(options = {})
      @options = RecorderOptions.new(options)
      @video   = nil
      @process = nil
      initialize_logger(@options.log_level)
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
      @process
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

    #
    # Discards the recorded file. Useful in automated testing
    # when a test passes and the recorded file is no longer
    # needed.
    #
    def discard
      FileUtils.rm options.output
    end

    alias_method :delete, :discard

    private

    #
    # Launches the ffmpeg binary using a generated command based on
    # the given options.
    #
    def start_ffmpeg
      raise RecorderErrors::DependencyNotFound, 'ffmpeg binary not found.' unless ffmpeg_exists?

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
    rescue Errno::EPIPE
      # Gets last line from log file
      err_line = get_lines_from_log(:last, 2)
      raise FFMPEG::Error, err_line
    end

    #
    # Initializes the logger with the given log level.
    #
    def initialize_logger(level)
      FFMPEG.logger.progname  = 'FFmpeg'
      FFMPEG.logger.level     = level || Logger::ERROR
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

    #
    # Returns true if ffmpeg binary is found.
    #
    def ffmpeg_exists?
      return !`which ffmpeg`.empty? if OS.linux? # "" if not found

      return !`where ffmpeg`.empty? if OS.windows?

      # If the user does not use FFMPEG#ffmpeg_binary=() to set the binary path,
      # FFMPEG#ffmpeg_binary returns 'ffmpeg' assuming it must be in ENV. However,
      # if the above two checks fail, it is not in the ENV either.
      return false if FFMPEG.ffmpeg_binary == 'ffmpeg'

      true
    end

    #
    # Returns lines from the log file
    #
    def get_lines_from_log(position = :last, count = 2)
      f     = File.open(options.log)
      lines = f.readlines
      lines = lines.last(count) if position == :last
      lines = lines.first(count) if position == :first
      f.close

      lines.join(' ')
    end
  end # class Recorder
end # module FFMPEG
