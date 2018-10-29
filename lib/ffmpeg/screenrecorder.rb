require 'streamio-ffmpeg'
require 'os'
require_relative 'recorder_options'

module FFMPEG
  class Screenrecorder
    attr_reader :video

    def initialize(options = {})
      @options = RecorderOptions.new(options)
      @video   = nil
      @process = nil
      init_logger(@options.values[:logging_level])
    end

    def options
      @options.values
    end

    def start
      @video     = nil # New file
      start_time = Time.now
      @process   = start_ffmpeg
      elapsed    = Time.now - start_time
      FFMPEG.logger.debug "Process started in #{elapsed}s"
      FFMPEG.logger.info 'Recording...'
    end

    def stop
      FFMPEG.logger.debug 'Stopping ffmpeg.exe...'
      elapsed = kill_ffmpeg
      FFMPEG.logger.debug "Stopped ffmpeg.exe in #{elapsed}s"
      FFMPEG.logger.info 'Recording complete.'
      @video = Movie.new(options[:output])
    end

    # def inputs(application)
    #   FFMPEG.logger.debug "Retrieving available windows from: #{application}"
    #   available_inputs_by application
    # end

    private

    def start_ffmpeg
      FFMPEG.logger.debug "Command: #{command}"
      IO.popen(command, 'r+')
    end

    def kill_ffmpeg
      @process.puts 'q' # Gracefully exit ffmpeg
      elapsed = wait_for_io_eof(5)
      @process.close_write # Close IO
      elapsed
    end

    def init_logger(level)
      FFMPEG.logger.progname  = 'FFMPEG'
      FFMPEG.logger.level     = level || Logger::INFO
      FFMPEG.logger.formatter = proc do |severity, time, progname, msg|
        "#{time.strftime('%F %T')} #{progname} - #{severity} - #{msg}\n"
      end
      FFMPEG.logger.debug "Logger initialized."
    end

    def command
      cmd = "#{FFMPEG.ffmpeg_binary} -y "
      cmd << @options.parsed_values
    end

    def wait_for_io_eof(timeout)
      start = Time.now
      Timeout.timeout(timeout) do
        sleep(0.1) until @process.eof?
      end
      Time.now - start
    end

    # def available_inputs_by(application)
    #   `tasklist /v /fi "imagename eq #{application}.exe" /fo list | findstr  Window`
    #     .split("\n")
    #     .reject { |title| title == 'Window Title: N/A' }
    # end
    #
    # def input
    #   return options[:input] if options[:input] == 'desktop'
    #   %Q(title="#{options[:input].gsub('Window Title: ', '')}")
    # end
  end # class Recorder
end # module FFMPEG
