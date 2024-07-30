# frozen_string_literal: true

module ScreenRecorder
  #
  # @api private
  #
  # @since 1.7.0
  #
  # Combined version of:
  # https://github.com/SeleniumHQ/selenium/blob/trunk/rb/lib/selenium/webdriver/common/child_process.rb
  # https://github.com/enkessler/childprocess/blob/master/lib/childprocess/process_spawn_process.rb
  class ChildProcess
    TimeoutError = Class.new(StandardError)

    SIGINT = 'INT'
    SIGTERM = 'TERM'
    SIGKILL = 'KILL'

    POLL_INTERVAL = 0.1

    attr_accessor :detach, :pid
    attr_writer :io

    def initialize(*command)
      @command = command
      @detach = false
      @pid = nil
      @status = nil
    end

    def io
      @io ||= ::IO.pipe
    end

    def start
      options = { :in => io, %i[out err] => io } # to log file

      if OS.windows?
        options[:new_pgroup] = true
      else
        options[:pgroup] = true
      end

      @pid = Process.spawn(*@command, options)
      ScreenRecorder.logger.debug("  -> pid: #{@pid}")

      Process.detach(@pid) if detach
    end

    def stop(timeout = 3)
      return unless @pid
      return if exited?

      ScreenRecorder.logger.debug("Sending TERM to process: #{@pid}")
      interrupt
      poll_for_exit(timeout)

      ScreenRecorder.logger.debug("  -> stopped #{@pid}")
    rescue TimeoutError, Errno::EINVAL
      ScreenRecorder.logger.debug("    -> sending KILL to process: #{@pid}")
      kill
      wait
      ScreenRecorder.logger.debug("      -> killed #{@pid}")
    end

    def alive?
      @pid && !exited?
    end

    def exited?
      return true if @exit_code

      ScreenRecorder.logger.debug("Checking if #{@pid} is exited...")
      pid, @status = ::Process.waitpid2(@pid, ::Process::WNOHANG | ::Process::WUNTRACED)
      return false if @status.nil?

      pid = nil if pid.zero? # may happen on jruby
      @exit_code = @status.exitstatus || @status.termsig if pid
      ScreenRecorder.logger.debug("  -> exit code is #{@exit_code.inspect}")

      !!pid
    rescue Errno::ECHILD
      # may be thrown for detached processes
      true
    end

    def poll_for_exit(timeout)
      ScreenRecorder.logger.debug("Polling #{timeout} seconds for exit of #{@pid}")

      end_time = Time.now + timeout
      sleep POLL_INTERVAL until exited? || Time.now > end_time

      raise TimeoutError, "  ->  #{@pid} still alive after #{timeout} seconds" unless exited?
    end

    def wait
      return if exited?

      _, @status = waitpid2(@pid)
    end

    private

    def exit_code=(status)
      @exit_code = status.exitstatus || status.termsig
    end

    def interrupt
      return if exited?

      send_signal(SIGINT)
    end

    def terminate
      return if exited?

      send_signal(SIGTERM)
    end

    def kill
      return if exited?

      send_signal(SIGKILL)
    rescue Errno::ECHILD, Errno::ESRCH
      # already dead
    end

    def send_signal(sig)
      ScreenRecorder.logger.debug("Sending #{sig} to process: #{@pid}")
      if OS.windows?
        Process.kill sig, @pid # process only
        return
      end

      Process.kill sig, -@pid # negative pid == process group
    end

    def waitpid2(pid, flags = 0)
      Process.waitpid2(pid, flags)
    rescue Errno::ECHILD
      true # already dead
    end
  end # ChildProcess
end # Common
