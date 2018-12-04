require_relative '../spec_helper'

RSpec.describe FFMPEG::ScreenRecorder do
  context 'given the gem is loaded' do
    it 'has a version number' do
      expect(FFMPEG::ScreenRecorder::VERSION).not_to be nil
    end

    it 'it can find the FFmpeg binary' do
      # noinspection RubyResolve
      expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
    end
  end

  describe '#new' do
    context 'user provides all required options' do
      let(:opts) do
        { output:    'recorder-output.mkv',
          infile:    'desktop',
          framerate: 30.0 }
      end
      let(:recorder) { FFMPEG::ScreenRecorder.new(opts) }

      it 'sets the options' do
        expect(recorder.options.all).to eql(opts)
      end

      it 'defaults FFMPEG.logger.level to Logger::ERROR' do
        expect(FFMPEG.logger.level).to eql(Logger::ERROR)
      end

      it 'sets @video to nil' do
        expect(recorder.video).to be_nil
      end
    end

    context 'user does not provide required options' do
      it 'raises an error when required options are not provided' do
        expect { FFMPEG::ScreenRecorder.new({}) }.to raise_exception(ArgumentError)
      end
    end
  end # describe #new

  context 'given FFMPEG::ScreenRecorder has been initialized' do
    describe '#options' do
      let(:opts) do
        { output:    'recorder-output.mkv',
          infile:    'desktop',
          framerate: 30.0 }
      end
      let(:recorder) { FFMPEG::ScreenRecorder.new(opts) }

      it 'returns a Hash of options' do
        expect(recorder.options.all).to be_a(Hash)
      end

      it 'returns valid format for current OS' do
        expected_format = if OS.windows?
                            'gdigrab'
                          elsif OS.linux?
                            'x11grab'
                          elsif OS.mac?
                            'avfoundation'
                          else
                            raise NotImplementedError, 'Your OS is not supported.'
                          end
        expect(recorder.options.format).to eql(expected_format)
      end

      it 'sets log file name to the default name' do
        expect(recorder.options.log).to eq('ffmpeg.log')
      end
    end

    describe '#start' do
      let(:opts) do
        { output:    'recorder-output.mkv',
          infile:    'desktop',
          framerate: 30.0,
          log:       'recorder-log.txt' }
      end
      let(:recorder) { FFMPEG::ScreenRecorder.new(opts) }

      before do
        recorder.start
        sleep(1.0)
      end

      it 'sets @video to nil' do
        expect(recorder.video).to be_nil
      end

      it 'creates a log file based on opts[:log]' do
        expect(File).to exist(recorder.options.log)
      end

      # Clean up
      after do
        recorder.stop
        FileUtils.rm recorder.options.output
        FileUtils.rm recorder.options.log
      end
    end
  end # context

  context 'the user is ready to stop the recording' do
    let(:opts) do
      { output:    'recorder-output.mkv',
        infile:    'desktop',
        framerate: 30.0 }
    end
    let(:recorder) { FFMPEG::ScreenRecorder.new(opts) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    describe '#stop' do
      it 'outputs a video file' do
        expect(File).to exist(recorder.options.output)
      end

      it 'outputs video with the user given FPS' do
        expect(recorder.video.frame_rate).to equal(recorder.options.framerate)
      end
    end

    describe '#video' do
      it 'returns a valid video file' do
        expect(recorder.video.valid?).to be(true)
      end
    end

    # Clean up
    after do
      FileUtils.rm recorder.options.output
    end
  end # context

  context 'the user provides an invalid option' do
    let(:opts) do
      { output: 'recorder-output.mkv',
        infile: 'myscreen', # Invalid option
        framerate: 30.0 }
    end
    let(:recorder) { FFMPEG::ScreenRecorder.new(opts) }

    before do
      recorder.start
      sleep(1.0)
    end

    describe '#stop' do
      it 'raises an exception and prints ffmpeg error to console' do
        expect { recorder.stop }.to raise_exception(FFMPEG::Error)
      end
    end

    #
    # Clean up
    #
    after do
      FileUtils.rm recorder.options.log
    end
  end

  #
  # Application/Window Recording
  #
  describe '.window_titles' do
    context 'given a firefox window is open' do
      let(:browser) do
        Webdrivers.install_dir = 'webdrivers_bin'
        Watir::Browser.new :firefox
      end

      it 'returns a list of available windows from firefox' do
        browser.wait
        expect(FFMPEG::RecordingRegions.fetch('firefox')).to be_a_kind_of(Array)
      end

      it 'does not return an empty list' do
        browser.wait
        expect(FFMPEG::RecordingRegions.fetch('firefox').empty?).to be(false)
      end

      it 'returns the title of the currently open window' do
        browser.goto 'google.com'
        browser.wait
        expect(FFMPEG::RecordingRegions.fetch('firefox').first).to eql('Google - Mozilla Firefox')
      end

      after { browser.quit }
    end # context

    context 'given a firefox window is not open' do
      it 'raises an exception' do
        expect { FFMPEG::RecordingRegions.fetch('firefox') }.to raise_exception(FFMPEG::RecorderErrors::ApplicationNotFound)
      end
    end # context
  end # describe

  #
  # Windows Only
  #
  if OS.windows? # Only gdigrab supports window capture
    describe '#start with opts[:infile] as "Mozilla Firefox"' do
      let(:browser) do
        Webdrivers.install_dir = 'webdrivers_bin'
        Watir::Browser.new :firefox
      end
      let(:opts) do
        { output:    'firefox-recorder.mp4',
          infile:    'Mozilla Firefox',
          framerate: 30,
          log:       'ffmpeg-log.txt',
          log_level: Logger::DEBUG }
      end
      let(:recorder) { FFMPEG::ScreenRecorder.new opts }

      it 'can record a specific firefox window with given title' do
        # Note: browser is lazily loaded with let
        browser.window.resize_to 1280, 720
        recorder.start
        browser.goto 'watir.com'
        browser.link(text: 'News').wait_until_present.click
        browser.wait
        recorder.stop
        browser.quit

        expect(File).to exist(recorder.options.output)
        expect(recorder.video.valid?).to be(true)
      end

      #
      # Clean up
      #
      after do
        FileUtils.rm recorder.options.output
        FileUtils.rm recorder.options.log
      end
    end # describe
  end # Os.windows?
end # describe FFMPEG::ScreenRecorder
