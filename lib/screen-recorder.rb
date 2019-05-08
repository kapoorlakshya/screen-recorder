require 'childprocess'
require 'logger'
require 'os'
require 'streamio-ffmpeg'

# @since 1.0.0.beta11
module ScreenRecorder
  #
  # Uses user given FFMPEG binary
  #
  # @example
  #   ScreenRecorder.ffmpeg_binary = 'C:\ffmpeg.exe'
  #
  def self.ffmpeg_binary=(bin)
    FFMPEG.ffmpeg_binary = bin
  end

  #
  # Returns path to ffmpeg binary
  #
  def self.ffmpeg_binary
    FFMPEG.ffmpeg_binary
  end

  #
  # Set external logger if you want.
  #
  def self.logger=(log)
    @logger = log
  end

  #
  # ScreenRecorder.logger
  #
  def self.logger
    return @logger if @logger

    logger           = Logger.new(STDOUT)
    logger.level     = Logger::ERROR
    logger.progname  = 'ScreenRecorder'
    logger.formatter = proc do |severity, time, progname, msg|
      "#{time.strftime('%F %T')} #{progname} - #{severity} - #{msg}\n"
    end
    logger.debug 'Logger initialized.'
    @logger = logger
  end
end

require 'screen-recorder/type_checker'
require 'screen-recorder/errors'
require 'screen-recorder/options'
require 'screen-recorder/titles'
require 'screen-recorder/common'
require 'screen-recorder/desktop'
require 'screen-recorder/window'