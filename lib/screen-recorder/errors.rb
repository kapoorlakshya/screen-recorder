module ScreenRecorder
  # @since 1.0.0-beta5
  module Errors
    # @since 1.0.0-beta3
    class ApplicationNotFound < StandardError
      def message
        'expected application was not found by ffmpeg.'
      end
    end

    # @since 1.0.0-beta5
    class DependencyNotFound < StandardError
      def message
        'ffmpeg binary path not set or not found in ENV.'
      end
    end
  end
end