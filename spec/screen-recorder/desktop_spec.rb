RSpec.describe ScreenRecorder::Desktop do
  describe '#new' do
    let(:recorder) { described_class.new(output: test_options) }

    it 'accepts input: as a parameter' do
      expect { described_class.new(input: test_input, output: test_output) }.not_to raise_exception
    end

    # @todo Figure out how to test this on Travis since default is 1 and Travis uses 0.
    unless OS.mac?
      it 'defaults to OS specific input if none is given' do
        expect(described_class.new(output: test_output).options.input).to eq(test_input)
      end
    end

    it 'accepts output: as a parameter' do
      expect { described_class.new(output: test_output) }.not_to raise_exception
    end

    it 'wants output as required parameter' do
      # noinspection RubyArgCount
      expect { described_class.new }.to raise_exception(ArgumentError)
    end
  end # describe #new

  describe '#new with advanced parameters' do
    let(:recorder) { described_class.new(output: output, advanced: test_advanced) }

    it 'expects advanced: as a Hash' do
      expect { described_class.new(output: output, advanced: []) }.to raise_exception(ArgumentError)
    end

    it 'sets advanced parameters' do
      expect(recorder.options.advanced).to eq(test_advanced)
    end
  end

  describe '#options' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    it 'returns a ScreenRecorder::Options object' do
      expect(recorder.options).to be_a(ScreenRecorder::Options)
    end
  end

  describe '#start' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    before do
      recorder.start
      sleep(1.0)
    end

    after do
      recorder.stop
      delete_file recorder.options.output
      delete_file recorder.options.log
    end

    it 'sets @video to nil' do
      expect(recorder.video).to be_nil
    end

    it 'creates a log file' do
      expect(File).to exist(recorder.options.log)
    end
  end # context

  context 'when the user is ready to stop the recording' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    after do
      delete_file recorder.options.output
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
  end # context

  context 'when the guser wants to discard the video' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    #
    # Clean up
    #
    after do
      delete_file recorder.options.log
    end

    describe '#discard' do
      it 'discards the recorded video' do
        recorder.discard
        expect(File).not_to exist(recorder.options.output)
      end

      it 'also works as #delete' do
        expect(recorder.method(:discard)).to eql(recorder.method(:delete))
      end
    end
  end

  describe 'user wants to record the desktop' do
    let(:browser) do
      Webdrivers.install_dir = 'webdrivers_bin'
      Watir::Browser.new :firefox
    end
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    #
    # Clean up
    #
    after do
      delete_file recorder.options.output
      delete_file recorder.options.log
    end

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
  end
end # RSpec.describe