# @since 1.0.0-beta11
module ScreenRecorder
  # @since 1.0.0-beta11
  class Options
    DEFAULT_LOG_FILE = 'ffmpeg.log'.freeze
    DEFAULT_FPS      = 15.0

    def initialize(options)
      TypeChecker.check options, Hash
      TypeChecker.check options[:advanced], Hash if options[:advanced]
      @options = verify_options options

      unless advanced[:framerate]
        @options[:advanced][:framerate] = DEFAULT_FPS
      end
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
      @options[:advanced]
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
      @options[:log] || DEFAULT_LOG_FILE
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
      vals << advanced_options unless advanced.empty?
      vals << "-i #{input} "
      vals << output
      vals << ffmpeg_log_to(log) # If provided
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
      @options[:advanced].each do |k, v|
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
      return advanced[:input_device] if advanced[:input_device]

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
