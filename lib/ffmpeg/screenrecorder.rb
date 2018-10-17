require 'streamio-ffmpeg'
require 'os'

module FFMPEG
  class Recorder
    attr_reader :opts, :output, :process_id

    def initialize(opts = {})
      @opts       = default_config.merge opts
      @output     = @opts[:output]
      @video_file = nil
      @process_id = nil
    end

    def start
      @video_file = nil # New file
      @process_id = spawn(command)
    end

    def stop
      # return Process.kill('EXIT', @process_id) if OS.linux?
      `TASKKILL /f /pid ffmpeg.exe`
      # Process.detach(@process_id)
    end

    def inputs
      %w[desktop]
    end

    def video_file
      @video_file ||= Movie.new(output)
    end

    private

    def default_config
      { input:     'desktop',
        framerate: 15,
        device:    'gdigrab',
        log:       'ffmpeg_log.txt' }
    end

    def command
      # "ffmpeg -f gdigrab -framerate 15 -i desktop output.mkv 2> log.txt"
      "#{ffmpeg} -y -f #{opts[:device]} -framerate #{opts[:framerate]} -i #{opts[:input]} #{opts[:output]} 2> #{@opts[:log]}"
    end

  end
end
