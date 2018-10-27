require_relative '../spec_helper'

RSpec.describe FFMPEG::Screenrecorder do
  context 'given the gem is loaded' do
    it 'has a version number' do
      expect(FFMPEG::Screenrecorder::VERSION).not_to be nil
    end

    it 'it can find the FFMPEG binary' do
      expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
    end
  end

  before(:all) do
    @opts               = { output:        'ffmpeg-screenrecorder-rspec-output.mkv',
                            input:         'desktop',
                            framerate:     30.0,
                            device:        'gdigrab',
                            extra_opts:    { video_size: '1024x768' },
                            logging_level: Logger::DEBUG,
                            log:           'ffmpeg-recorder-log.txt' }
    FFMPEG.logger.level = Logger::WARN # To test the switch to DEBUG
    @recorder           = FFMPEG::Screenrecorder.new(@opts)
    @browser            = nil
  end

  describe '#new' do
    it 'sets the opts' do
      expect(@recorder.opts).to eql(@opts)
    end

    it 'sets FFMPEG.logger.level to user defined level from opts[:logging_level]' do
      expect(FFMPEG.logger.level).to eql(@recorder.opts[:logging_level])
    end
  end

  context 'given FFMPEG::Screenrecorder has been initialized' do
    describe '#opts' do
      it 'returns a Hash of options' do
        expect(@recorder.opts).to be_a(Hash)
      end
    end
  end # context

  context 'given the user is ready to start recording' do
    describe '#start' do
      it 'returns pid' do
        pid = @recorder.start
        expect(pid).to be_a_kind_of(Integer)
      end

      it 'creates a log file based on name in #opts' do
        sleep(1.0) # Wait for file generation
        expect(File).to exist(@recorder.opts[:log])
      end

      after(:all) do
        duration = 7.0
        puts "Waiting #{duration}s for recording to complete..."
        sleep(duration) # Takes at least 7s to create a valid recording
      end
    end
  end # context

  context 'the user is ready to stop the record' do
    describe '#stop' do
      it 'returns a SUCCESS message' do
        expect(@recorder.stop).to include('SUCCESS')
      end

      it 'outputs a file' do
        expect(File).to exist(@recorder.output)
      end
    end
  end # context

  context 'given the user wants to read the file' do
    describe '#video_file' do
      it 'returns a valid video file' do
        expect(@recorder.video_file.valid?).to be(true)
      end
    end
  end # context

  context 'given FFMPEG::Screenrecorder accepts user defined parameters' do
    describe '#opts[:extra_opts]' do
      it 'records at the given FPS' do
        expect(@recorder.video_file.frame_rate).to equal(@recorder.opts[:framerate])
      end

      it 'records at user given resolution' do
        expect(@recorder.video_file.resolution).to eq(@recorder.opts[:extra_opts][:video_size])
      end

      #
      # Clean up log and output file
      #
      # after(:all) do
      #   FileUtils.rm @recorder.output
      #   sleep(0.5)
      #   FileUtils.rm @recorder.opts[:log]
      # end
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
  #     @recorder.opts = opts
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
  #     FileUtils.rm @recorder.opts[:log]
  #   end
  # end # context
end # RSpec.describe