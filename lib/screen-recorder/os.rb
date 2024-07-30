module ScreenRecorder
  # @api private
  module OS
    module_function

    def home
      @home ||= Dir.home
    end

    def engine
      @engine ||= RUBY_ENGINE.to_sym
    end

    def os
      host_os = RbConfig::CONFIG['host_os']
      @os ||= case host_os
              when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
                :windows
              when /darwin|mac os/
                :macosx
              when /linux/
                :linux
              when /solaris|bsd/
                :unix
              else
                raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
              end
    end

    def jruby?
      engine == :jruby
    end

    def truffleruby?
      engine == :truffleruby
    end

    def ruby_version
      RUBY_VERSION
    end

    def windows?
      os == :windows
    end

    def mac?
      os == :macosx
    end

    def linux?
      os == :linux
    end

    def unix?
      os == :unix
    end

    def wsl?
      return false unless linux?

      File.read('/proc/version').downcase.include?('microsoft')
    rescue Errno::EACCES
      # the file cannot be accessed on Linux on DeX
      false
    end

    def cygwin?
      RUBY_PLATFORM.include?('cygwin')
    end

    def null_device
      File::NULL
    end

    def cygwin_path(path, only_cygwin: false, **opts)
      return path if only_cygwin && !cygwin?

      flags = []
      opts.each { |k, v| flags << "--#{k}" if v }

      `cygpath #{flags.join ' '} "#{path}"`.strip
    end

    def unix_path(path)
      path.tr(File::ALT_SEPARATOR, File::SEPARATOR)
    end

    def windows_path(path)
      path.tr(File::SEPARATOR, File::ALT_SEPARATOR)
    end
  end # OS
end