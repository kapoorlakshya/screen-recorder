module FFMPEG
  # @since 1.0.0-beta4
  module RecordingRegions
    #
    # Returns a list of available window titles for the given application (process) name.
    #
    def window_titles(application)
      FFMPEG.logger.debug "Retrieving available windows for: #{application}"
      WindowGrabber.new.available_windows_for application
    end

    # @since 1.0.0-beta4
    class WindowGrabber
      #
      # Returns a cleaned up list of available window titles
      # for the given application (process) name.
      # Note: Only supports Windows OS as of version beta2.
      #
      def available_windows_for(application)
        windows_os(application) if OS.windows?
        linux_os(application) if OS.linux?
      end

      private

      def windows_os(application)
        raw_list   = `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
                     .split("\n")
                     .reject { |title| title == 'Window Title: N/A' }
        final_list = raw_list.map { |i| i.gsub('Window Title: ', '') } # Make it user friendly
        raise RecorderErrors::ApplicationNotFound, "No open windows found for: #{application}.exe" if final_list.empty?

        final_list
      end

      def linux_os(application)
        raise DependencyNotFound, 'wmctrl is not installed. Run: sudo apt-get install wmctrl.' unless wmctrl_installed?

        final_list = `wmctrl -l | awk '{$3=""; $2=""; $1=""; print $0}'` # Returns all open windows
                     .split("\n")
                     .map(&:strip)
                     .select { |t| t.match?(/#{application}/i) } # Narrow down to given application
        raise RecorderErrors::ApplicationNotFound, "No open windows found for: #{application}" if final_list.empty?

        final_list
      end

      def wmctrl_installed?
        !`which wmctrl`.empty? # "" when not found
      end
    end
  end # module Windows
end # module FFMPEG