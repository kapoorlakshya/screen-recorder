module ScreenRecorder
  # @since 1.0.0-beta4
  module Titles
    # Regex to filter out "Window Title: N/A" from Chrome extensions and "Window Title: ".
    # This is done to remove unusable titles and to match the Ffmpeg expected input format
    # for capturing specific windows.
    # For example, "Window Title: Google - Mozilla Firefox" becomes "Google - Mozilla Firefox".
    FILTERED_TITLES = %r{^Window Title:( N/A|\s+)?}.freeze

    #
    # Returns a list of available window titles for the given application (process) name.
    #
    # @return [Array]
    def self.fetch(application)
      ScreenRecorder.logger.debug "Retrieving available windows for: #{application}"
      WindowGrabber.new.available_windows_for application
    end

    # @since 1.0.0-beta4
    #
    # @api private
    class WindowGrabber
      #
      # Returns a list of available window titles for the given application (process) name.
      #
      def available_windows_for(application)
        raise NotImplementedError, 'Only Microsoft Windows (gdigrab) supports window capture.' unless OS.windows?

        titles = `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
                   .split("\n")
                   .map { |i| i.gsub(FILTERED_TITLES, '') }
                   .reject(&:empty?)
        raise Errors::ApplicationNotFound, "No open windows found for: #{application}.exe" if titles.empty?

        warn_on_mismatch(titles, application)
        titles
      end

      private

      #
      # Prints a warning if the retrieved list of window titles does no include
      # the given application process name, which applications commonly do.
      #
      def warn_on_mismatch(titles, application)
        return if titles.map(&:downcase).join(',').include? application.to_s

        ScreenRecorder.logger.warn "Process name and window title(s) do not match: #{titles}"
        ScreenRecorder.logger.warn 'Please manually provide the displayed window title.'
      end
    end # class WindowGrabber
  end # module Windows
end # module FFMPEG