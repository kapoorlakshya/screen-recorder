RSpec.describe ScreenRecorder::Options do
  let(:options) { described_class.new(test_options) }

  describe 'new' do
    it '#accepts a Hash' do
      expect { described_class.new(test_options) }.not_to raise_exception # ArgumentError
    end

    it 'raise ArgumentError if user provides an object other than a Hash' do
      expect { described_class.new([]) }.to raise_exception(ArgumentError)
    end

    it 'raises an error when a required option (ex: output) is not provided' do
      expect { described_class.new(input: test_input) }.to raise_exception(ArgumentError)
    end
  end

  describe '#capture_device' do
    it 'returns capture device based on current OS' do
      expect(options.capture_device).to eql(test_capture_device)
    end
  end

  describe '#input' do
    it 'returns user given input value' do
      expect(options.input).to eql(test_options[:input])
    end
  end

  describe '#output' do
    it 'returns user given output value' do
      expect(options.output).to eql(test_options[:output])
    end
  end

  describe '#advanced' do
    it 'returns Hash of advanced options' do
      expect(options.advanced).to be_an_instance_of(Hash)
    end

    it 'raise ArgumentError if user provides an object other than a Hash' do
      bad_test_options = { output:   test_output,
                           input:    test_input,
                           advanced: %w[let me fool you] }
      expect { described_class.new(bad_test_options) }.to raise_exception(ArgumentError)
    end

    it 'defaults input pixel format to uyvy422 on macOS', if: OS.mac? do
      expect(options.advanced[:input][:pix_fmt]).to eql('uyvy422')
    end

    it 'does not default input pixel format to yuv420p on Windows and Linux', if: !OS.mac? do
      expect(options.advanced[:input][:pix_fmt]).to be_nil
    end

    it 'defaults output pixel format to yuv420p' do
      expect(options.advanced[:output][:pix_fmt]).to eql('yuv420p')
    end

    it 'defaults output framerate' do
      opts = described_class.new(input: test_input, output: test_output)
      expect(opts.framerate).to be(ScreenRecorder::Options::DEFAULT_FPS)
    end

    it 'uses video scaling fix if output pixel format is yuv420p' do
      expect(options.advanced[:output][:vf]).to eql(ScreenRecorder::Options::YUV420P_SCALING)
    end
  end

  describe '#log' do
    context 'when the user given log filename' do
      it 'returns user given log filename' do
        expect(described_class.new(test_options).log).to eql(test_options[:advanced][:log])
      end
    end

    context 'when user does not provide a log filename' do
      let(:test_options) do
        { input:  test_input,
          output: test_output }
      end

      it 'returns default log filename' do
        expect(described_class.new(test_options).log).to eql(ScreenRecorder::Options::DEFAULT_LOG_FILE)
      end
    end
  end

  describe '#parsed' do
    it 'returns a String of parsed parameters' do
      expect(options.parsed).to be_an_instance_of(String)
    end
  end # #parsed
end # Rspec.describe