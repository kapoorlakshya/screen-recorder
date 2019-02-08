module ScreenRecorder
  # @since 1.0.0-beta5
  module Errors
    # @since 1.0.0-beta3
    class ApplicationNotFound < StandardError; end

    # @since 1.0.0-beta5
    class DependencyNotFound < StandardError; end
  end
end