module FFMPEG
  # @since 1.0.0-beta2
  module Windows

    #
    # Returns a list of available window titles for the given application (process) name.
    #
    def window_titles(application)
      FFMPEG.logger.debug "Retrieving available windows for: #{application}"
      WindowGrabber.new.available_windows_for application
    end

    # @since 1.0.0-beta2
    class WindowGrabber
      #
      # Returns a cleaned up list of available window titles
      # for the given application (process) name.
      # Note: Only supports Windows OS as of version beta2.
      #
      def available_windows_for(application)
        raw_list   = `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
                       .split("\n")
                       .reject { |title| title == 'Window Title: N/A' }
        final_list = raw_list.map { |i| i.gsub('Window Title: ', '') } # Make it user friendly

        raise ApplicationNotFound, "No open windows found for: #{application}.exe" if final_list.empty?
        final_list
      end
    end

    # @since 1.0.0-beta3
    class ApplicationNotFound < StandardError; end
  end # module Windows
end # module FFMPEG