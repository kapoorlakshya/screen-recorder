# @since 1.0.0-beta11
module ScreenRecorder
  # @since 1.0.0-beta11
  class Desktop < Common
    DEFAULT_INPUT_LINUX = ':0.0'
    DEFAULT_INPUT_WIN   = 'desktop'

    #
    # Desktop recording specific initializer.
    #
    def initialize(input: 'desktop', output:, advanced: {})
      super(input: determine_input(input), output: output, advanced: advanced)
    end

    private

    #
    # Returns FFmpeg expected input value based on current OS
    #
    def determine_input(val)
      if OS.linux?
        return DEFAULT_INPUT_LINUX if val == 'desktop'
        return val # Custom $DISPLAY number in Linux
      end
      return DEFAULT_INPUT_WIN if OS.windows?

      raise ArgumentError, "Unsupported input type: '#{val}'. Expected: 'desktop'"
    end
  end
end