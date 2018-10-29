module FFMPEG
  class RecorderOptions

    def initialize(options)
      @options = verify_options options
    end

    def format
      @options[:format]
    end

    def framerate
      @options[:framerate]
    end

    def infile
      @options[:infile]
    end

    def output
      @options[:output]
    end

    def advanced
      @options[:advanced]
    end

    def log
      @options[:log]
    end

    def log_level
      @options[:log_level]
    end

    def all
      @options
    end

    def parsed
      vals = "-f #{@options[:format]} "
      vals << "-r #{@options[:framerate]} "
      vals << advanced_options if @options[:advanced]
      vals << "-i #{determine_infile @options[:infile]} "
      vals << @options[:output]
      vals << ffmpeg_log_to(@options[:log]) # If provided
    end

    private

    #
    # Verifies the required options are provided
    #
    def verify_options(options)
      missing_options = required_options.select { |req| options[req].nil? }
      raise "Required options are missing: #{missing_options}" unless missing_options.empty?

      options
    end

    #
    # Returns Array of require options a Symbols
    #
    def required_options
      # -f format
      # -r framerate
      # -i input
      # output
      %i[format framerate infile output]
    end

    #
    # Returns advanced options parsed and ready for ffmpeg to receive.
    #
    def advanced_options
      return nil unless @options[:advanced]
      raise ':advanced cannot be empty.' if options[:advanced].empty?

      arr = []
      options[:advanced].each { |k, v|
        arr.push "-#{k} #{v}"
      }
      arr.join(' ') + ' '
    end

    #
    # Determines if the ffmpeg output will be to a log
    # file based on given options.
    #
    def ffmpeg_log_to(file)
      return " 2> #{file}" if file
      ' > nul 2>&1' # No log file given
    end

    #
    # Adds title= qualifier to infile parameter
    # unless the user is recording the desktop.
    #
    def determine_infile(opt)
      return opt if opt == 'desktop'
      %Q("title=#{opt}")
    end
  end
end