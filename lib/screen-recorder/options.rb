# @since 1.0.0-beta11
module ScreenRecorder
  # @since 1.0.0-beta11
  class Options
    DEFAULT_LOG_FILE       = 'ffmpeg.log'.freeze
    DEFAULT_FPS            = 15.0
    DEFAULT_INPUT_PIX_FMT  = 'uyvy422'.freeze # For macOS / avfoundation
    DEFAULT_OUTPUT_PIX_FMT = 'yuv420p'.freeze

    def initialize(options)
      TypeChecker.check options, Hash
      TypeChecker.check options[:advanced], Hash if options[:advanced]
      @options = verify_options options
      advanced[:framerate] ||= DEFAULT_FPS
      advanced[:log]       ||= DEFAULT_LOG_FILE
      advanced[:pix_fmt]   ||= DEFAULT_OUTPUT_PIX_FMT
    end

    #
    # Returns given input file or input
    #
    def input
      @options[:input]
    end

    #
    # Returns capture device in use
    #
    def capture_device
      determine_capture_device
    end

    #
    # Returns given output filepath
    #
    def output
      @options[:output]
    end

    #
    # Returns given values that are optional
    #
    def advanced
      @options[:advanced] ||= {}
    end

    #
    # Returns given framerate
    #
    def framerate
      advanced[:framerate]
    end

    #
    # Returns given log filename
    #
    def log
      advanced[:log]
    end

    #
    # Returns all given options
    #
    def all
      @options
    end

    #
    # Returns a String with all options parsed and
    # ready for the ffmpeg process to use
    #
    def parsed
      vals = "-f #{capture_device} "
      vals << "-pix_fmt #{DEFAULT_INPUT_PIX_FMT} " if OS.mac? # Input pixel format
      vals << advanced_options unless advanced.empty?
      vals << "-i #{input} "
      vals << "-pix_fmt #{advanced[:pix_fmt]} " if advanced[:pix_fmt] # Output pixel format
      # Fix for using yuv420p
      # @see https://www.reck.dk/ffmpeg-libx264-height-not-divisible-by-2/
      vals << '-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" ' if advanced[:pix_fmt] == 'yuv420p'
      vals << output
      vals << ffmpeg_log_to(log)
    end

    private

    #
    # Verifies the required options are provided and returns
    # the given options Hash. Raises ArgumentError if all required
    # options are not present in the given Hash.
    #
    def verify_options(options)
      missing_options = required_options.select { |req| options[req].nil? }
      err             = "Required options are missing: #{missing_options}"
      raise(ArgumentError, err) unless missing_options.empty?

      options
    end

    #
    # Returns Array of required options as Symbols
    #
    def required_options
      %i[input output]
    end

    #
    # Returns advanced options parsed and ready for ffmpeg to receive.
    #
    def advanced_options
      arr = []

      # Log file and output pixel format is handled separately
      # at the end of the command
      advanced.reject { |k, _| %i[log pix_fmt].include? k }
        .each do |k, v|
        arr.push "-#{k} #{v}"
      end
      arr.join(' ') + ' '
    end

    #
    # Returns logging command with user given log file
    # from options or the default file.
    #
    def ffmpeg_log_to(file)
      file ||= DEFAULT_LOG_FILE
      " 2> #{file}"
    end

    #
    # Returns input capture device based on user given value or the current OS.
    #
    def determine_capture_device
      # User given capture device or format
      # @see https://www.ffmpeg.org/ffmpeg.html#Main-options
      return advanced[:f] if advanced[:f]
      return advanced[:fmt] if advanced[:fmt]

      if OS.windows?
        'gdigrab'
      elsif OS.linux?
        'x11grab'
      elsif OS.mac?
        'avfoundation'
      else
        raise NotImplementedError, 'Your OS is not supported.'
      end
    end
  end
end
