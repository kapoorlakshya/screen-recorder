# @since 1.0.0-beta11
module ScreenRecorder
  # @since 1.0.0-beta11
  #
  # @api private
  class Common
    PROCESS_TIMEOUT = 5 # Seconds to wait for ffmpeg to quit

    attr_reader :options, :video

    def initialize(input:, output:, advanced: {})
      raise Errors::DependencyNotFound unless ffmpeg_exists?

      @options = Options.new(input: input, output: output, advanced: advanced)
      @video   = nil
      @process = nil
    end

    #
    # Starts the recording
    #
    def start
      ScreenRecorder.logger.debug 'Starting recorder...'
      @video   = nil # New file
      @process = start_ffmpeg
      ScreenRecorder.logger.info 'Recording...'
      @process
    end

    #
    # Stops the recording
    #
    def stop
      ScreenRecorder.logger.debug 'Stopping ffmpeg...'
      stop_ffmpeg
      ScreenRecorder.logger.debug 'Stopped ffmpeg.'
      ScreenRecorder.logger.info 'Recording complete.'
      @video = prepare_video
    end

    #
    # Discards the recorded file. Useful in automated testing
    # when a test passes and the recorded file is no longer
    # needed.
    #
    def discard
      FileUtils.rm options.output
    end

    alias delete discard

    private

    #
    # Launches the ffmpeg binary using a generated command based on
    # the given options.
    #
    def start_ffmpeg
      ScreenRecorder.logger.debug "Command: #{command}"
      process           = build_command
      @log_file         = File.new(options.log, 'w+')
      process.io.stdout = process.io.stderr = @log_file
      @log_file.sync    = true
      process.duplex    = true
      process.start
      sleep(1.5) # Takes ~1.5s on average to initialize
      # Stopped because of an error
      raise FFMPEG::Error, "Failed to start ffmpeg. Reason: #{lines_from_log(:last, 2)}" if process.exited?

      process
    end

    #
    # Sends 'q' to the ffmpeg binary to gracefully stop the process.
    # Forcefully terminates it if it takes more than 5s.
    #
    def stop_ffmpeg
      @process.io.stdin.puts 'q' # Gracefully exit ffmpeg
      @process.io.stdin.close
      @log_file.close
      @process.poll_for_exit(PROCESS_TIMEOUT)
      @process.exit_code
    rescue ChildProcess::TimeoutError
      ScreenRecorder.logger.error 'FFmpeg failed to stop. Force killing it...'
      @process.stop # Tries increasingly harsher methods to kill the process.
      ScreenRecorder.logger.error "Check '#{@options.log}' for more information."
    end

    #
    # Runs ffprobe on the output video file and returns
    # a FFMPEG::Movie object.
    #
    def prepare_video
      max_attempts  = 3
      attempts_made = 0
      delay         = 1.0

      begin # Fixes #79
        ScreenRecorder.logger.info 'Running ffprobe to prepare video (output) file.'
        FFMPEG::Movie.new(options.output)
      rescue Errno::EAGAIN, Errno::EACCES
        attempts_made += 1
        ScreenRecorder.logger.error "Failed to run ffprobe. Retrying... (#{attempts_made}/#{max_attempts})"
        sleep(delay)
        retry if attempts_made < max_attempts
        raise
      end
    end

    #
    # Generates the command line arguments based on the given
    # options.
    #
    def command
      cmd = "#{ScreenRecorder.ffmpeg_binary} -y "
      cmd << @options.parsed
    end

    #
    # Returns true if ffmpeg binary is found.
    #
    def ffmpeg_exists?
      return true if FFMPEG.ffmpeg_binary

      false
    rescue Errno::ENOENT # Raised when binary is not set in project or found in ENV
      false
    end

    #
    # Returns lines from the log file
    #
    def lines_from_log(position = :last, count = 2)
      f     = File.open(options.log)
      lines = f.readlines
      lines = lines.last(count) if position == :last
      lines = lines.first(count) if position == :first
      f.close

      lines.join(' ')
    end

    #
    # Returns OS specific arguments for Childprocess.build
    #
    def build_command
      ChildProcess.posix_spawn = true # Support JRuby.
      if OS.windows?
        ChildProcess.build('cmd.exe', '/c', command)
      else
        ChildProcess.build('sh', '-c', command)
      end
    end
  end
end