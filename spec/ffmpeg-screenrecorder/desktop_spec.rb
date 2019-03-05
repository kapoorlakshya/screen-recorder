RSpec.describe ScreenRecorder::Desktop do
  let(:input) {
    if OS.linux?
      number = `echo $DISPLAY`.strip
      puts "!!!!!!!!!!!! DISPLAY: #{number}"
      number ? number : ':0.0' # If $DISPLAY is not set, use default of :0.0
    else
      'desktop'
    end
  }
  let(:output) { 'recorded-file.mp4' }
  let(:log_file) { 'recorder.log' }
  let(:advanced) {
    { framerate: 30.0,
      loglevel:  'level+debug', # For FFmpeg
      video_size:  '640x480',
      show_region: '1' }
  }

  describe '#new' do
    let(:recorder) { ScreenRecorder::Desktop.new(output: output) }

    it 'accepts input: as a parameter' do
      expect { ScreenRecorder::Desktop.new(input: input, output: output) }.to_not raise_exception
    end

    it "defaults input as 'desktop' if none is given" do
      expect(ScreenRecorder::Desktop.new(output: output).options.input).to eq(input)
    end

    it 'accepts output: as a parameter' do
      expect { ScreenRecorder::Desktop.new(output: output) }.to_not raise_exception
    end

    it 'wants output as required parameter' do
      expect { ScreenRecorder::Desktop.new() }.to raise_exception(ArgumentError)
    end
  end # describe #new

  describe '#new with advanced parameters' do
    let(:recorder) { ScreenRecorder::Desktop.new(output: output, advanced: advanced) }

    it 'expects advanced: as a Hash' do
      expect { ScreenRecorder::Desktop.new(output: output, advanced: []) }.to raise_exception(ArgumentError)
    end

    it 'accepts advanced: as a parameter' do
      expect { ScreenRecorder::Desktop.new(output: output, advanced: advanced) }.to_not raise_exception
    end

    it 'sets advanced parameters' do
      expect(recorder.options.advanced).to eq(advanced)
    end

    it 'uses user given framerate' do
      expect(recorder.options.framerate).to eq(advanced[:framerate])
    end
  end

  describe '#options' do
    let(:recorder) { ScreenRecorder::Desktop.new(output: output) }

    it 'returns a FFMPEG::Options object' do
      expect(recorder.options).to be_a(ScreenRecorder::Options)
    end

    it 'stores output value' do
      expect(recorder.options.output).to be(output)
    end

    it 'stores input value' do
      expect(recorder.options.input).to eq(input)
    end

    it 'stores log file name' do
      expect(recorder.options.log).to eq('ffmpeg.log')
    end
  end

  describe '#start' do
    let(:recorder) { ScreenRecorder::Desktop.new(output: output) }

    before do
      recorder.start
      sleep(1.0)
    end

    it 'sets @video to nil' do
      expect(recorder.video).to be_nil
    end

    it 'creates a ffmpeg.log file' do
      expect(File).to exist(recorder.options.log)
    end

    # Clean up
    after do
      recorder.stop
      FileUtils.rm recorder.options.output
      FileUtils.rm recorder.options.log
    end
  end # context

  context 'the user is ready to stop the recording' do
    let(:recorder) { ScreenRecorder::Desktop.new(output: output) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    describe '#stop' do
      it 'outputs a video file' do
        expect(File).to exist(recorder.options.output)
      end

      it 'outputs video at default FPS' do
        expect(recorder.video.frame_rate).to eq(recorder.options.framerate)
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

  context 'user wants to discard the video' do
    let(:recorder) { ScreenRecorder::Desktop.new(output: output) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    describe '#discard' do
      it 'discards the recorded video' do
        recorder.discard
        expect(File).to_not exist(recorder.options.output)
      end

      it 'also works as #delete' do
        expect(recorder.method(:discard)).to eql(recorder.method(:delete))
      end
    end

    #
    # Clean up
    #
    after do
      FileUtils.rm recorder.options.log
    end
  end

  describe 'user wants to record the desktop' do
    let(:browser) {
      Webdrivers.install_dir = 'webdrivers_bin'
      Watir::Browser.new :firefox
    }
    let(:recorder) { ScreenRecorder::Desktop.new(output: output) }

    it 'can record the desktop' do
      # Note: browser is lazily loaded with let
      browser.window.resize_to 1280, 720
      recorder.start
      browser.goto 'watir.com'
      browser.link(text: 'News').wait_until(&:present?)
        .wait_while(&:obscured?).click
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
  end

#
# Windows Only
#
# if OS.windows? # Only gdigrab supports window capture
#   describe '#start with opts[:input] as "Mozilla Firefox"' do
#     let(:browser) do
#       Webdrivers.install_dir = 'webdrivers_bin'
#       Watir::Browser.new :firefox
#     end
#     let(:opts) do
#       { output:    'firefox-recorder.mp4',
#         input:     'Mozilla Firefox',
#         framerate: 15,
#         log:       'ffmpeg-log.txt',
#         log_level: Logger::DEBUG }
#     end
#     let(:recorder) { ScreenRecorder::Desktop.new(output: output) }
#
#     it 'can record a specific firefox window with given title' do
#       # Note: browser is lazily loaded with let
#       browser.window.resize_to 1280, 720
#       recorder.start
#       browser.goto 'watir.com'
#       browser.link(text: 'News').wait_until(&:present?).click
#       browser.wait
#       recorder.stop
#       browser.quit
#
#       expect(File).to exist(recorder.options.output)
#       expect(recorder.video.valid?).to be(true)
#     end
#
#     #
#     # Clean up
#     #
#     after do
#       FileUtils.rm recorder.options.output
#       FileUtils.rm recorder.options.log
#     end
#   end # describe
# end # Os.windows?
end # RSpec.describe