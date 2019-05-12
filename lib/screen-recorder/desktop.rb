# @since 1.0.0-beta11
module ScreenRecorder
  # @since 1.0.0-beta11
  class Desktop < Common
    DEFAULT_INPUT_WIN   = 'desktop'.freeze
    DEFAULT_INPUT_LINUX = ':0'.freeze
    DEFAULT_INPUT_MAC   = '1'.freeze

    #
    # Desktop recording mode.
    #
    def initialize(input: input_by_os, output:, advanced: {})
      super(input: determine_input(input), output: output, advanced: advanced)
    end

    private

    #
    # Returns default input value for current OS
    #
    def input_by_os
      return DEFAULT_INPUT_WIN if OS.windows?

      return DEFAULT_INPUT_LINUX if OS.linux?

      return DEFAULT_INPUT_MAC if OS.mac?

      raise 'Your OS is not supported. Feel free to create an Issue on GitHub.'
    end

    #
    # Returns FFmpeg expected input based on user given value or
    # default for the current OS.
    #
    def determine_input(val)
      return val if val

      input_by_os
    end
  end
end