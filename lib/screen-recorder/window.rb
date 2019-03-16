# @since 1.0.0-beta11
module ScreenRecorder
  # @since 1.0.0-beta11
  class Window < Common
    #
    # Window recording specific initializer.
    #
    def initialize(title:, output:, advanced: {})
      raise NotImplementedError, 'Window recording is only supported on Microsoft Windows.' unless OS.windows?

      super(input: format_input(title), output: output, advanced: advanced)
    end

    private

    #
    # Sets input syntax specific to the FFmpeg window recorder.
    #
    def format_input(title)
      %("title=#{title}")
    end
  end
end