# @since 1.0.0-beta11
module ScreenRecorder
  # @since 1.0.0-beta11
  class Window < Common
    #
    # Window recording mode.
    #
    def initialize(title:, output:, advanced: {})
      raise 'Window recording is only supported on Microsoft Windows.' unless OS.windows?

      super(input: %("title=#{title}"), output: output, advanced: advanced)
    end

    class << self
      #
      # Returns a list of available window titles for the given process (application) name.
      #
      # @return [Array]
      #
      # @example
      #   ScreenRecorder::Window.fetch_title('chrome')
      #   #=> ["New Tab - Google Chrome"]
      def fetch_title(process_name)
        ScreenRecorder.logger.debug "Retrieving window title for: #{process_name}"
        window_title_for process_name
      end

      private

      # Regex to filter out "Window Title: N/A" from Chrome extensions and "Window Title: ".
      # This is done to remove unusable titles and to match the Ffmpeg expected input format
      # for capturing specific windows.
      # For example, "Window Title: Google - Mozilla Firefox" becomes "Google - Mozilla Firefox".
      FILTERED_TITLES = %r{^Window Title:( N/A|\s+)?}.freeze

      def window_title_for(process_name)
        raise NotImplementedError, 'Only Microsoft Windows (gdigrab) supports window capture.' unless OS.windows?

        titles = `tasklist /v /fi "imagename eq #{process_name}.exe" /fo list | findstr  Window`
                   .split("\n")
                   .map { |i| i.gsub(FILTERED_TITLES, '') }
                   .reject(&:empty?)
        raise Errors::ApplicationNotFound, "No open windows found for: #{process_name}.exe" if titles.empty?

        warn_on_mismatch(titles, process_name)
        titles
      end

      def warn_on_mismatch(titles, process_name)
        return if titles.map(&:downcase).join(',').include? process_name.to_s

        ScreenRecorder.logger.warn "Process name and window title(s) do not match: #{titles}"
        ScreenRecorder.logger.warn 'Please manually provide the displayed window title.'
      end
    end
  end
end