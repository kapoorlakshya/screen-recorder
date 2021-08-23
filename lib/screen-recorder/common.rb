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
      exit_code = stop_ffmpeg
      return if exit_code == 1 # recording failed

      ScreenRecorder.logger.debug 'Stopped ffmpeg.'
      ScreenRecorder.logger.info 'Recording complete.'
      @video = prepare_video unless exit_code == 1
    end

    #
    # Discards the recorded file. Useful in automated testing
    # when a test passes and the recorded file is no longer
    # needed.
    #
    def discard
      File.delete options.output
    end

    alias delete discard

    private

    #
    # Launches the ffmpeg binary using a generated command based on
    # the given options.
    #
    def start_ffmpeg
      process = execute_command(ffmpeg_command, options.log)
      sleep(1.5) # Takes ~1.5s to initialize ffmpeg
      # Check if it exited unexpectedly
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
      wait_for_process_exit(@process)
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

    def ffmpeg_bin
      "#{ScreenRecorder.ffmpeg_binary} -y"
    end

    #
    # Generates the command line arguments based on the given
    # options.
    #
    def ffmpeg_command
      "#{ffmpeg_bin} #{@options.parsed}"
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
    # Executes the given command and outputs to the
    # optional logfile
    #
    def execute_command(cmd, logfile = nil)
      ScreenRecorder.logger.debug "Executing command: #{cmd}"
      process        = new_process(cmd)
      process.duplex = true
      if logfile
        @log_file         = File.new(logfile, 'w+')
        process.io.stdout = process.io.stderr = @log_file
        @log_file.sync    = true
      end
      process.start
      process
    end

    #
    # Calls Childprocess.new with OS specific arguments
    # to start the given process.
    #
    def new_process(process)
      ChildProcess.posix_spawn = true if RUBY_PLATFORM == 'java' # Support JRuby.
      if OS.windows?
        ChildProcess.new('cmd.exe', '/c', process)
      else
        ChildProcess.new('sh', '-c', process)
      end
    end

    #
    # Waits for given process to exit.
    # Forcefully kills the process if it does not exit within 5 seconds.
    # Returns exit code.
    #
    def wait_for_process_exit(process)
      process.poll_for_exit(PROCESS_TIMEOUT)
      process.exit_code # 0
    rescue ChildProcess::TimeoutError
      ScreenRecorder.logger.error 'ffmpeg failed to stop. Force killing it...'
      process.stop # Tries increasingly harsher methods to kill the process.
      ScreenRecorder.logger.error 'Forcefully killed ffmpeg. Recording failed!'
      1
    end
  end
end