require_relative '../spec_helper'

RSpec.describe FFMPEG::Screenrecorder do
  context 'given the gem is loaded' do
    it 'it can find the FFMPEG binary' do
      expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
    end
  end

  describe '#new' do
    context 'user provides all required options' do
      before(:all) { FFMPEG.logger.level = Logger::WARN } # To test the switch to DEBUG
      let(:opts) {
        { output:    'ffmpeg-screenrecorder-rspec-output.mkv',
          infile:    'desktop',
          format:    'gdigrab',
          framerate: 30.0,
          log_level: Logger::DEBUG }
      }
      let(:recorder) { FFMPEG::Screenrecorder.new(opts) }

      it 'sets the options' do
        expect(recorder.options.all).to eql(opts)
      end

      it 'sets FFMPEG.logger.level to user defined level from opts[:log_level]' do
        expect(FFMPEG.logger.level).to eql(recorder.options.log_level)
      end

      it 'sets @video to nil' do
        expect(recorder.video).to eql(nil)
      end
    end

    context 'user does not provide required options' do
      it 'raises an error when required options are not provided' do
        expect { FFMPEG::Screenrecorder.new({}) }.to raise_exception(ArgumentError)
      end
    end
  end # describe #new

  context 'given FFMPEG::Screenrecorder has been initialized' do
    describe '#options' do
      let(:opts) {
        { output:    'ffmpeg-screenrecorder-rspec-output.mkv',
          infile:    'desktop',
          format:    'gdigrab',
          framerate: 30.0 }
      }
      let(:recorder) { FFMPEG::Screenrecorder.new(opts) }

      it 'returns a Hash of options' do
        expect(recorder.options.all).to be_a(Hash)
      end
    end

    describe '#start' do
      let(:opts) {
        { output:    'ffmpeg-screenrecorder-rspec-output.mkv',
          infile:    'desktop',
          format:    'gdigrab',
          framerate: 30.0,
          log:       'ffmpeg-recorder-log.txt' }
      }
      let(:recorder) { FFMPEG::Screenrecorder.new(opts) }

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
    let(:opts) {
      { output:    'ffmpeg-screenrecorder-rspec-output.mkv',
        infile:    'desktop',
        format:    'gdigrab',
        framerate: 30.0 }
    }
    let(:recorder) { FFMPEG::Screenrecorder.new(opts) }

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

  context 'given a firefox window is open' do
    describe '.window_titles' do
      before(:each) do
        # Facing a weird issue where the .webdrivers folder is not found
        # after the first time geckodriver is downloaded,
        # @todo Troubleshoot and remove this temporary fix.
        `TASKKILL /f /im firefox.exe`
        `TASKKILL /f /im geckodriver.exe`
        FileUtils.rm_rf('C:\Users\Lakshya Kapoor\.webdrivers')
      end

      let(:browser) { Watir::Browser.new :firefox }

      it 'returns a list of available windows from firefox' do
        browser.wait
        expect(FFMPEG::Screenrecorder.window_titles('firefox')).to be_a_kind_of(Array)
      end

      it 'returns the title of the currently open window' do
        browser.goto 'google.com'
        browser.wait
        expect(FFMPEG::Screenrecorder.window_titles('firefox').first).to eql('Google - Mozilla Firefox')
      end

      after { browser.quit }
    end
  end

  context 'given a firefox widow is open and available to record', :specific_window do
    describe '#start with opts[:infile] as "title=Mozilla Firefox"' do
      before do
        # Facing a weird issue where the .webdrivers folder is not found
        # after the first time geckodriver is downloaded,
        # @todo Troubleshoot and remove this temporary fix.
        `TASKKILL /f /im firefox.exe`
        `TASKKILL /f /im geckodriver.exe`
        FileUtils.rm_rf('C:\Users\Lakshya Kapoor\.webdrivers')
      end

      let(:browser) { Watir::Browser.new :firefox }
      let(:opts) {
        { output:    'firefox-recorder.mp4',
          infile:    'Mozilla Firefox',
          format:    'gdigrab',
          framerate: 30,
          log:       'ffmpeg-log.txt',
          log_level: Logger::DEBUG }
      }
      let(:recorder) { FFMPEG::Screenrecorder.new opts }

      before do
        # Facing a weird issue where the .webdrivers folder is not found
        # after the first time geckodriver is downloaded,
        # @todo Troubleshoot and remove this temporary fix.
        FileUtils.rm_rf('C:\Users\Lakshya Kapoor\.webdrivers')
      end

      it 'can record a firefox window while user navigates to various websites' do
        # Note: browser is lazily loaded with let
        browser.window.resize_to 1280, 720
        recorder.start
        browser.goto 'google.com'
        browser.goto 'watir.com'
        browser.goto 'github.com'
        browser.goto 'stackoverflow.com'
        browser.link(text: 'Ask Question').click
        browser.wait
        recorder.stop
        browser.quit

        expect(File).to exist(recorder.options.output)
        expect(recorder.video.valid?).to be(true)
      end

      #
      # Clean up log and output file
      #
      after do
        FileUtils.rm recorder.options.output
        FileUtils.rm recorder.options.log
      end
    end # describe
  end # context
end # describe FFMPEG::Screenrecorder