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
      @video = nil # New file
      @process = start_ffmpeg
      raise 'FFmpeg process failed to start.' unless @process.alive?

      ScreenRecorder.logger.info 'Recording...'
      @process
    end

    #
    # Stops the recording
    #
    def stop
      ScreenRecorder.logger.debug 'Stopping ffmpeg...'

      @process.stop

      @process.poll_for_exit(PROCESS_TIMEOUT)
      if @process.alive?
        ScreenRecorder.logger.error "Failed to stop ffmpeg (pid: #{@process.pid}). Please kill it manually."
        return
      end

      ScreenRecorder.logger.debug 'Stopped ffmpeg.'
      ScreenRecorder.logger.info 'Preparing video...'
      @video = prepare_video
      ScreenRecorder.logger.info 'Recording ready.'
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
      process = execute_command(ffmpeg_command)
      sleep(1.5) # Takes ~1.5s to initialize ffmpeg
      # Check if it exited unexpectedly
      if process.exited?
        raise FFMPEG::Error,
              "Failed to start command: #{ffmpeg_command}\n\nReason: #{lines_from_log(:last, 10)}"
      end

      process
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
      cmd = "#{ffmpeg_bin} #{@options.parsed}"

      return "</dev/null #{cmd}" unless OS.windows?

      cmd
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
    #
    def execute_command(cmd, log = options.log)
      ScreenRecorder.logger.debug "Log: #{log}"
      ScreenRecorder.logger.debug "Executing command: #{cmd}"
      process = new_process(cmd)
      process.detach = true
      FileUtils.touch(log)
      process.io = log
      process.start
      process
    end

    #
    # Calls ChildProcess.new with OS specific arguments
    # to start the given process.
    #
    def new_process(process)
      if OS.windows?
        ChildProcess.new('powershell.exe', '/c', process)
      else
        ChildProcess.new(process)
      end
    end
  end
end
