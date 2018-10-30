module FFMPEG
  module Windows

    def window_titles(application)
      FFMPEG.logger.debug "Retrieving available windows for: #{application}"
      WindowGrabber.new.available_windows_for application
    end

    class WindowGrabber
      def available_windows_for(application)
        list = `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
                 .split("\n")
                 .reject { |title| title == 'Window Title: N/A' }
        list.map { |i| i.gsub('Window Title: ', '') } # Make it user friendly
      end
    end
  end # module Windows
end # module FFMPEG