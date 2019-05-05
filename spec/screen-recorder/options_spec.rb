RSpec.describe ScreenRecorder::Options do
  let(:recorder) { described_class.new(test_options) }

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
      expect(recorder.capture_device).to eql(test_capture_device)
    end
  end

  describe '#framerate' do
    let(:recorder) { described_class.new(input: test_input, output: test_output) }

    it 'returns default framerate value if none given' do
      expect(recorder.framerate).to eql(ScreenRecorder::Options::DEFAULT_FPS)
    end
  end

  describe '#input' do
    it 'returns user given input value' do
      expect(recorder.input).to eql(test_options[:input])
    end
  end

  describe '#output' do
    it 'returns user given output value' do
      expect(recorder.output).to eql(test_options[:output])
    end
  end

  context 'when the user wants to provide advanced options' do
    describe '#advanced' do
      it 'returns Hash of advanced options' do
        expect(recorder.advanced).to eql(test_options[:advanced])
      end

      it 'raise ArgumentError if user provides an object other than a Hash' do
        bad_test_options = { output:   test_output,
                             input:    test_input,
                             advanced: %w[let me fool you] }
        expect { described_class.new(bad_test_options) }.to raise_exception(ArgumentError)
      end
    end

    describe '#framerate' do
      it 'returns user given framerate value' do
        expect(described_class.new(test_options).framerate).to eql(test_options[:advanced][:framerate])
      end
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

  describe '#all' do
    it 'returns Hash of all user given options' do
      expect(recorder.all).to eql(test_options)
    end
  end

  describe '#parsed' do
    context 'when the environment is Windows or Linux', if: !OS.mac? do
      let(:expected_parsed_value) do
        "-f #{test_capture_device} -framerate #{test_options[:advanced][:framerate]} -loglevel #{test_options[:advanced][:loglevel]}" \
          " -video_size #{test_options[:advanced][:video_size]} -show_region #{test_options[:advanced][:show_region]}" \
          " -i #{test_options[:input]} -pix_fmt #{test_options[:advanced][:pix_fmt]}" \
          ' -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2"' \
          " #{test_options[:output]} 2> #{test_options[:advanced][:log]}"
      end

      it 'returns parsed options for FFmpeg' do
        expect(described_class.new(test_options).parsed).to eql(expected_parsed_value)
      end
    end

    context 'when the environment is macOS', if: OS.mac? do
      let(:expected_parsed_value) do
        "-f #{test_capture_device} -pix_fmt uyvy422 -framerate #{test_options[:advanced][:framerate]}" \
          " -loglevel #{test_options[:advanced][:loglevel]} -video_size #{test_options[:advanced][:video_size]}" \
          " -show_region #{test_options[:advanced][:show_region]} " \
          "-i #{test_options[:input]} -pix_fmt #{test_options[:advanced][:pix_fmt]}" \
          ' -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2"' \
          " #{test_options[:output]} 2> #{test_options[:advanced][:log]}"
      end

      it 'includes input -pix_fmt in parsed options for FFmpeg' do
        expect(described_class.new(test_options).parsed).to eql(expected_parsed_value)
      end

      it 'prevents Ffmpeg from raising a warning about unsupported input pixel format' do
        recorder = ScreenRecorder::Desktop.new(input: test_input, output: test_output)
        recorder.start
        sleep(1.0)
        recorder.stop
        no_warning = File.readlines(recorder.options.log)
                       .grep(/Selected pixel format (.+) is not supported/)
                       .empty?
        expect(no_warning).to be true

        delete_file recorder.options.log
      end
    end # context
  end # #parsed
end # Rspec.describe