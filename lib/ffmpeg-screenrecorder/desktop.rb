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

    def determine_input(val)
      return DEFAULT_INPUT_LINUX if val == 'desktop' && OS.linux? # Default
      return val if OS.linux? # Custom $DISPLAY number in Linux
      return DEFAULT_INPUT_WIN if val == 'desktop' # Microsoft Windows

      raise ArgumentError, "Unsupported input type: '#{val}'. Expected: 'desktop'"
    end

  end
end