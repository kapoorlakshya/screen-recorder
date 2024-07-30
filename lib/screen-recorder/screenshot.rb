module ScreenRecorder
  # All screenshot related code
  module Screenshot
    #
    # Takes a screenshot in the current context (input) - desktop or current window
    #
    def screenshot(filename, resolution = nil, log = 'ffmpeg.log')
      ScreenRecorder.logger.debug "Screenshot filename: #{filename}, resolution: #{resolution}"
      cmd = screenshot_cmd(filename: filename, resolution: resolution)
      process = execute_command(cmd, log) # exits when done
      process.poll_for_exit(5)

      if process.exited?
        ScreenRecorder.logger.info "Screenshot: #{filename}"
        return filename
      end

      ScreenRecorder.logger.error 'Failed to take a screenshot.'
      nil
    end

    #
    # Parameters to capture a single frame
    #
    def screenshot_cmd(filename:, resolution: nil)
      resolution = resolution ? resolution_arg(resolution) : nil
      # -f overwrites existing file
      "#{ffmpeg_bin} -f #{options.capture_device} -i #{options.input} -framerate 1 -frames:v 1 #{resolution}#{filename}"
    end

    private

    #
    # Returns OS specific video resolution arg for ffmpeg
    #
    def resolution_arg(size)
      "-s #{size} "
    end
  end
end
