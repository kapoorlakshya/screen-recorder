require_relative '../spec_helper'

RSpec.describe FFMPEG::Recorder do
  before(:all) do
    @opts               = { output:        'ffmpeg-screenrecorder-rspec-output.mkv',
                            input:         'desktop',
                            framerate:     30.0,
                            device:        'gdigrab',
                            extra_opts:    { video_size: '1024x768' },
                            logging_level: Logger::DEBUG,
                            log:           'ffmpeg-recorder-log.txt' }
    FFMPEG.logger.level = Logger::WARN # To test the switch to DEBUG
    @recorder           = FFMPEG::Recorder.new(@opts)
    @browser            = nil
  end

  describe '#new' do
    it 'sets FFMPEG.logger.level to user defined level from opts[:logging_level]' do
      expect(FFMPEG.logger.level).to eql(@recorder.opts[:logging_level])
    end

    it 'sets the opts' do
      expect(@recorder.opts).to eql(@opts)
    end
  end

  context 'given FFMPEG::Recorder has been initialized' do
    describe '#opts' do
      it 'returns a Hash of options' do
        expect(@recorder.opts).to be_a(Hash)
      end
    end

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
        duration = 10.0
        puts "Waiting #{duration}s for recording to complete..."
        sleep(duration) # Takes 10s to create a valid recording
      end
    end

    describe '#stop' do
      it 'returns a SUCCESS message' do
        expect(@recorder.stop).to include('SUCCESS')
      end

      it 'creates an output file' do
        expect(File).to exist(@recorder.output)
      end

      describe '#video_file' do
        it 'returns a valid video file' do
          expect(@recorder.video_file.valid?).to be(true)
        end
      end
    end
  end # context

  context 'given FFMPEG::Recorder accepts user defined parameters' do
    describe '#opts[:extra_opts]' do
      it 'records at the given FPS' do
        expect(@recorder.video_file.frame_rate).to equal(@recorder.opts[:framerate])
      end

      it 'records at user given resolution' do
        expect(@recorder.video_file.resolution).to eq(@recorder.opts[:extra_opts][:video_size])
      end
    end
  end # context

  context 'given a firefox window is open' do
    before(:all) do
      # Facing a weird issue where the .webdrivers folder is not found
      # after the first time geckodriver is downloaded,
      # @todo Troubleshoot and remove this temporary fix.
      FileUtils.rm_rf('C:\Users\Lakshya Kapoor\.webdrivers')

      @browser = Watir::Browser.new :firefox
      @browser.goto 'google.com'
    end

    describe '#inputs' do
      it 'returns a list of available browser windows as inputs (recording regions)' do
        expect(@recorder.inputs('firefox')).to be_a_kind_of(Array)
      end

      it 'returns the title of the currently open browser window' do
        expect(@recorder.inputs('firefox').first).to eql('Window Title: Google - Mozilla Firefox')
      end
    end

    after(:all) do
      @browser.quit
    end
  end # context

# it 'can record a browser window' do
#   browser = Watir::Browser.new :firefox
#   browser.resize_to(800, 600)
#   browser.goto 'google.com'
#   inputs = FFMPEG::Recorder.inputs # Tab with title as Google
#
#   opts     = { output:    'C:\ffmpeg-screenrecorder-rspec-output.mkv',
#                input:     inputs.first,
#                framerate: 15 }
#   recorder = FFMPEG::Screenrecorder.new(opts)
#   recorder.start
#   3.times { browser.refresh }
#   recorder.stop
#
#   # @todo Can't think of a valid test for this...
# end
#
  after(:all) do
    FileUtils.rm @recorder.output
    sleep(0.5)
    FileUtils.rm @recorder.opts[:log]
  end
end