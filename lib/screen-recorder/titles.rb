module ScreenRecorder
  # @since 1.0.0-beta4
  module Titles
    #
    # Returns a list of available window titles for the given process (application) name.
    #
    # @return [Array]
    #
    # @example
    #   ScreenRecorder::Titles.fetch('chrome')
    #   #=> ["New Tab - Google Chrome"]
    def self.fetch(application)
      # @todo Remove Titles.fetch in v2.0
      Window.fetch_title application
    end
  end # module Windows
end # module FFMPEG