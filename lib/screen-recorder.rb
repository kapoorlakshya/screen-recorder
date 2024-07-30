require 'logger'
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
    ScreenRecorder.logger.debug 'Setting ffmpeg path...'
    FFMPEG.ffmpeg_binary = bin
    ScreenRecorder.logger.debug "ffmpeg path set: #{bin}"
    ScreenRecorder.ffmpeg_binary
  end

  #
  # Returns path to ffmpeg binary or raises DependencyNotFound
  #
  def self.ffmpeg_binary
    FFMPEG.ffmpeg_binary
  rescue Errno::ENOENT # Raised when binary is not set in project or found in ENV
    raise Errors::DependencyNotFound
  end

  #
  # Uses user given ffprobe binary
  #
  # @example
  #   ScreenRecorder.ffprobe_binary= = 'C:\ffprobe.exe'
  #
  def self.ffprobe_binary=(bin)
    ScreenRecorder.logger.debug 'Setting ffprobe path...'
    FFMPEG.ffprobe_binary = bin
    ScreenRecorder.logger.debug "ffprobe path set: #{bin}"
    ScreenRecorder.ffmpeg_binary
  end

  #
  # Returns path to ffprobe binary or raises DependencyNotFound
  #
  def self.ffprobe_binary
    FFMPEG.ffprobe_binary
  rescue Errno::ENOENT # Raised when binary is not set in project or found in ENV
    raise Errors::DependencyNotFound
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

    logger = Logger.new($stdout)
    logger.level = Logger::ERROR
    logger.progname = 'ScreenRecorder'
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
require 'screen-recorder/screenshot'
require 'screen-recorder/desktop'
require 'screen-recorder/window'
require 'screen-recorder/childprocess'
require 'screen-recorder/os'