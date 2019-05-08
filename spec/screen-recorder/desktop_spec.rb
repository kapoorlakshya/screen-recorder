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
    end

    it 'sets @video to nil' do
      expect(recorder.video).to be_nil
    end

    it 'creates a log file' do
      expect(File).to exist(recorder.options.log)
    end
  end

  context 'when the user provides invalid ffmpeg arguments' do
    let(:recorder) do
      described_class.new(input:    test_input,
                          output:   test_output,
                          advanced: { input: { pix_fmt: 'abc' } })
    end

    it 'raises an error' do
      expect { recorder.start }.to raise_error(FFMPEG::Error)
    end
  end

  describe '#stop' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    it 'outputs a video file' do
      expect(File).to exist(recorder.options.output)
    end
  end

  describe '#video' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    it 'returns a valid video file' do
      expect(recorder.video.valid?).to be(true)
    end
  end

  describe '#discard' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    before do
      recorder.start
      sleep(1.0)
      recorder.stop
    end

    it 'discards the recorded video' do
      recorder.discard
      expect(File).not_to exist(recorder.options.output)
    end

    it 'also works as #delete' do
      expect(recorder.method(:discard)).to eql(recorder.method(:delete))
    end
  end
end # RSpec.describe