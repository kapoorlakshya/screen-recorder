require_relative '../spec_helper'

RSpec.describe FFMPEG::Screenrecorder do
  context 'given the gem is loaded' do
    it 'it can find the FFMPEG binary' do
      expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
    end
  end

  before(:all) do
    @opts               = { output:        'ffmpeg-screenrecorder-rspec-output.mkv',
                            infile:        'desktop',
                            format:        'gdigrab',
                            framerate:     30.0,
                            log_level: Logger::DEBUG,
                            log:           'ffmpeg-recorder-log.txt' }
    FFMPEG.logger.level = Logger::WARN # To test the switch to DEBUG
    @recorder           = FFMPEG::Screenrecorder.new(@opts)
    @browser            = nil
  end

  describe '#new' do
    it 'sets the opts' do
      expect(@recorder.options.all).to eql(@opts)
    end

    it 'sets FFMPEG.logger.level to user defined level from opts[:log_level]' do
      expect(FFMPEG.logger.level).to eql(@recorder.options.log_level)
    end
  end

  context 'given FFMPEG::Screenrecorder has been initialized' do
    describe '#opts' do
      it 'returns a Hash of options' do
        expect(@recorder.options.all).to be_a(Hash)
      end
    end
  end # context

  context 'given the user is ready to start recording' do
    describe '#start' do
      before(:all) do
        @recorder.start
      end

      it 'creates a log file based on name in #opts' do
        sleep(0.5) # Wait for file generation
        expect(File).to exist(@recorder.options.log)
      end

      after(:all) do
        duration = 7.0
        puts "Waiting #{duration}s for recording to complete..."
        sleep(duration) # Takes at least 7s to create a valid recording
      end
    end
  end # context

  context 'the user is ready to stop the record' do
    before(:all) do
      @recorder.stop
    end

    describe '#stop' do
      it 'outputs a video file' do
        expect(File).to exist(@recorder.options.output)
      end

      it 'returns a valid video file' do
        expect(@recorder.video.valid?).to be(true)
      end

      # it 'returns a 7s long video recording' do
      #   expect(@recorder.video.duration).to be_between(7.00, 8.00)
      # end
    end
  end # context

  context 'given the user wants to read the file' do
    describe '#video_file' do
      it 'returns a valid video file' do
        expect(@recorder.video.valid?).to be(true)
      end
    end
  end # context

  context 'given FFMPEG::Screenrecorder accepts user defined parameters' do
    describe '#opts[:extra_opts]' do
      it 'records at the given FPS' do
        expect(@recorder.video.frame_rate).to equal(@recorder.options.framerate)
      end

      #
      # Clean up log and output file
      #
      after(:all) do
        FileUtils.rm @recorder.options.output
        FileUtils.rm @recorder.options.log
      end
    end
  end # context

  # context 'given a firefox window is open' do
  #   describe '#inputs' do
  #     before(:all) do
  #       # Facing a weird issue where the .webdrivers folder is not found
  #       # after the first time geckodriver is downloaded,
  #       # @todo Troubleshoot and remove this temporary fix.
  #       FileUtils.rm_rf('C:\Users\Lakshya Kapoor\.webdrivers')
  #
  #       @browser = Watir::Browser.new :firefox
  #       @browser.goto 'google.com'
  #     end
  #
  #     it 'returns a list of available browser windows as inputs (recording regions)' do
  #       expect(@recorder.inputs('firefox')).to be_a_kind_of(Array)
  #     end
  #
  #     it 'returns the title of the currently open browser window' do
  #       expect(@recorder.inputs('firefox').first).to eql('Window Title: Google - Mozilla Firefox')
  #     end
  #
  #     after(:all) do
  #       @browser.quit
  #     end
  #   end
  # end

  # context 'given a firefox widow is open and available to record', :specific_window do
  #   it 'can record a specific browser window' do
  #     # Facing a weird issue where the .webdrivers folder is not found
  #     # after the first time geckodriver is downloaded,
  #     # @todo Troubleshoot and remove this temporary fix.
  #     FileUtils.rm_rf('C:\Users\Lakshya Kapoor\.webdrivers')
  #
  #     @browser = Watir::Browser.new :firefox
  #     @browser.window.resize_to 800, 600
  #
  #     opts           = { output:        'output.mp4',
  #                        input:         @recorder.inputs('firefox').first,
  #                        framerate:     30,
  #                        logging_level: Logger::DEBUG }
  #     @recorder.options = opts
  #
  #     @recorder.start
  #     @browser.goto 'google.com'
  #     @browser.goto 'watir.com'
  #     @browser.goto 'github.com'
  #     @recorder.stop
  #     @browser.quit
  #
  #     expect(File).to exist(@recorder.output)
  #     expect(@recorder.video_file.valid?).to be(true)
  #   end
  #
  #   #
  #   # Clean up log and output file
  #   #
  #   after(:all) do
  #     FileUtils.rm @recorder.output
  #     sleep(0.5)
  #     FileUtils.rm @recorder.options[:log]
  #   end
  # end # context
end # RSpec.describe