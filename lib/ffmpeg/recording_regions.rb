module FFMPEG
  # @since 1.0.0-beta4
  module RecordingRegions
    #
    # Returns a list of available window titles for the given application (process) name.
    #
    def self.fetch(application)
      FFMPEG.logger.debug "Retrieving available windows for: #{application}"
      WindowGrabber.new.available_windows_for application
    end

    # @since 1.0.0-beta4
    class WindowGrabber
      #
      # Returns a cleaned up list of available window titles
      # for the given application (process) name.
      #
      def available_windows_for(application)
        return windows_os_window(application) if OS.windows?
        return linux_os_window(application) if OS.linux?

        raise NotImplementedError, 'Your OS is not supported.'
      end

      private

      #
      # Returns list of windows when using Microsoft Windows
      #
      def windows_os_window(application)
        raw_list   = `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
                       .split("\n")
                       .reject { |title| title == 'Window Title: N/A' }
        final_list = raw_list.map { |i| i.gsub('Window Title: ', '') } # Match ffmpeg expected format
        raise RecorderErrors::ApplicationNotFound, "No open windows found for: #{application}.exe" if final_list.empty?

        final_list
      end

      #
      # Returns list of windows when using Linux
      #
      def linux_os_window(application)
        FFMPEG.logger.warn 'Note: Default capture device x11grab on Linux does not support window recording.'
        raise DependencyNotFound, 'wmctrl is not installed. Run: sudo apt-get install wmctrl.' unless wmctrl_installed?

        final_list = `wmctrl -l | awk '{$3=""; $2=""; $1=""; print $0}'` # Returns all open windows
                       .split("\n")
                       .map(&:strip)
                       .select { |t| t.match?(/#{application}/i) } # Narrow down to given application
        raise RecorderErrors::ApplicationNotFound, "No open windows found for: #{application}" if final_list.empty?

        final_list
      end

      #
      # Returns true if wmctrl is installed
      #
      def wmctrl_installed?
        !`which wmctrl`.empty? # "" when not found
      end
    end
  end # module Windows
end # module FFMPEG