# @since 1.0.0-beta11
#
# @api private
module ScreenRecorder
  # @since 1.0.0-beta11
  class Options
    attr_reader :all

    DEFAULT_LOG_FILE          = 'ffmpeg.log'.freeze
    DEFAULT_FPS               = 15.0
    DEFAULT_MAC_INPUT_PIX_FMT = 'uyvy422'.freeze # For avfoundation
    DEFAULT_PIX_FMT           = 'yuv420p'.freeze
    YUV420P_SCALING           = '"scale=trunc(iw/2)*2:trunc(ih/2)*2"'.freeze

    def initialize(options)
      # @todo Consider using OpenStruct
      @all                 = verify_options options
      advanced[:input]     = default_advanced_input.merge(advanced_input)
      advanced[:output]    = default_advanced_output.merge(advanced_output)
      advanced[:log] ||= DEFAULT_LOG_FILE

      # Fix for using yuv420p pixel format for output
      # @see https://www.reck.dk/ffmpeg-libx264-height-not-divisible-by-2/
      advanced_output[:vf] = YUV420P_SCALING if advanced_output[:pix_fmt] == 'yuv420p'
    end

    #
    # Returns given input file or input
    #
    def input
      @all[:input]
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
      @all[:output]
    end

    #
    # Returns given values that are optional
    #
    def advanced
      @all[:advanced] ||= {}
    end

    #
    # Returns given framerate
    #
    def framerate
      ScreenRecorder.logger.warn '#framerate will not be available in the next release. Use #advanced instead.'
      advanced[:output][:framerate]
    end

    #
    # Returns given log filename
    #
    def log
      advanced[:log]
    end

    #
    # Returns a String with all options parsed and
    # ready for the ffmpeg process to use
    #
    def parsed
      vals = "-f #{capture_device} "
      vals << parse_advanced(advanced_input)
      vals << "-i #{input} "
      vals << parse_advanced(advanced_output)
      vals << parse_advanced(advanced)
      vals << output
    end

    private

    #
    # Verifies the required options are provided and returns
    # the given options Hash. Raises ArgumentError if all required
    # options are not present in the given Hash.
    #
    def verify_options(options)
      TypeChecker.check options, Hash
      TypeChecker.check options[:advanced], Hash if options[:advanced]
      missing_options = required_options.select { |req| options[req].nil? }
      err             = "Required options are missing: #{missing_options}"
      raise(ArgumentError, err) unless missing_options.empty?

      options
    end

    def advanced_input
      advanced[:input] ||= {}
    end

    def advanced_output
      advanced[:output] ||= {}
    end

    def default_advanced_input
      {
        pix_fmt: OS.mac? ? DEFAULT_MAC_INPUT_PIX_FMT : nil
      }
    end

    def default_advanced_output
      {
        pix_fmt:   DEFAULT_PIX_FMT,
        framerate: advanced[:framerate] || DEFAULT_FPS
      }
    end

    #
    # Returns Array of required options as Symbols
    #
    def required_options
      %i[input output]
    end

    #
    # Returns given Hash parsed and ready for ffmpeg to receive.
    #
    def parse_advanced(opts)
      # @todo Replace arr with opts.each_with_object([])
      arr = []
      # Do not parse input/output and log as they're placed separately in #parsed
      opts.reject { |k, _| %i[input output log].include? k }
        .each do |k, v|
        arr.push "-#{k} #{v}" unless v.nil? # Ignore blank params
      end
      arr.join(' ') + ' '
    end

    #
    # Returns input capture device based on user given value or the current OS.
    #
    def determine_capture_device
      # User given capture device or format
      # @see https://www.ffmpeg.org/ffmpeg.html#Main-options
      return advanced[:f] if advanced[:f]

      return advanced[:fmt] if advanced[:fmt]

      os_specific_capture_device
    end

    #
    # Returns input capture device for current OS.
    #
    def os_specific_capture_device
      return 'gdigrab' if OS.windows?

      return 'x11grab' if OS.linux?

      return 'avfoundation' if OS.mac?

      raise 'Your OS is not supported. Feel free to create an Issue on GitHub.'
    end
  end
end
