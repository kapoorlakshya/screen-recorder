module FFMPEG
  # @since 1.0.0-beta4
  module WindowTitles
    # Regex to filter out "Window Title: N/A" from Chrome extensions and "Window Title: ".
    # This is done to remove unusable titles and to match the Ffmpeg expected input format
    # for capturing specific windows.
    # For example, "Window Title: Google - Mozilla Firefox" becomes "Google - Mozilla Firefox".
    FILTERED_TITLES = %r{^Window Title:( N/A|\s+)?}

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
      # Returns list of window titles in FFmpeg expected format when using Microsoft Windows
      #
      def windows_os_window(application)
        titles = `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
                   .split("\n")
                   .map { |i| i.gsub(FILTERED_TITLES, '') }
                   .reject(&:empty?)
        raise RecorderErrors::ApplicationNotFound, "No open windows found for: #{application}.exe" if titles.empty?

        warn_on_mismatch(titles, application)
        titles
      end

      #
      # Returns list of window titles in FFmpeg expected format when using Linux
      #
      def linux_os_window(application)
        FFMPEG.logger.warn 'Default capture device on Linux (x11grab) does not support window recording.'
        raise DependencyNotFound, 'wmctrl is not installed. Run: sudo apt install wmctrl.' unless wmctrl_installed?

        titles = `wmctrl -l | awk '{$3=""; $2=""; $1=""; print $0}'` # Returns all open windows
                   .split("\n")
                   .map(&:strip)
                   .select { |t| t.match?(/#{application}/i) } # Narrow down to given application
        raise RecorderErrors::ApplicationNotFound, "No open windows found for: #{application}" if titles.empty?

        titles
      end

      #
      # Returns true if wmctrl is installed
      #
      def wmctrl_installed?
        !`which wmctrl`.empty? # "" when not found
      end

      #
      # Prints a warning if the retrieved list of window titles does no include
      # the given application process name, which applications commonly do.
      #
      def warn_on_mismatch(titles, application)
        unless titles.map(&:downcase).join(',').include? application.to_s
          FFMPEG.logger.warn "Process name and window title(s) do not match: #{titles}"
          FFMPEG.logger.warn "Please manually provide the displayed window title."
        end
      end
    end # class WindowGrabber
  end # module Windows
end # module FFMPEG