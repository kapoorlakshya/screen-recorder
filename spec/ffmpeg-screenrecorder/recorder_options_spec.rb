require_relative '../spec_helper'

RSpec.describe FFMPEG::RecorderOptions do
  let(:display) {
    if OS.linux?
      number = `echo $DISPLAY`.strip
      number ? number : ':0.0' # If $DISPLAY is not set, use default of 0.0
    else
      'desktop'
    end
  }

  let(:opts) do
    { input:     display,
      output:    'recorder-output.mkv',
      log_level: Logger::INFO,
      advanced:  { loglevel: 'level+debug', # For FFmpeg
                   video_size:  '640x480',
                   show_region: '1' } }
  end

  let(:os_specific_format) {
    return 'gdigrab' if OS.windows?
    return 'x11grab' if OS.linux?
    return 'avfoundation' if OS.mac?
  }

  let(:recorder_options) {
    FFMPEG::RecorderOptions.new(opts)
  }

  describe 'new' do
    it '#accepts a Hash' do
      expect { FFMPEG::RecorderOptions.new(opts) }.to_not raise_exception # ArgumentError
    end

    it 'raise ArgumentError if user provides an object other than a Hash' do
      expect { FFMPEG::RecorderOptions.new([]) }.to raise_exception(ArgumentError)
    end

    it 'raises an error when a required option (ex: output) is not provided' do
      expect { FFMPEG::RecorderOptions.new({ input: display, }) }.to raise_exception(ArgumentError)
    end
  end

  describe '#format' do
    it 'returns device format based on current OS' do
      expect(recorder_options.format).to eql(os_specific_format)
    end
  end

  describe '#framerate' do
    it 'returns default framerate value' do
      expect(recorder_options.framerate).to eql(FFMPEG::RecorderOptions::DEFAULT_FPS)
    end
  end

  describe '#input' do
    it 'returns user given input value' do
      expect(recorder_options.input).to eql(opts[:input])
    end
  end

  describe '#output' do
    it 'returns user given output value' do
      expect(recorder_options.output).to eql(opts[:output])
    end
  end

  context 'user wants to provide advanced options' do
    describe '#advanced' do
      it 'returns Hash of advanced options' do
        expect(recorder_options.advanced).to eql(opts[:advanced])
      end

      it 'raise ArgumentError if user provides an object other than a Hash' do
        bad_opts = { output:    'recorder-output.mkv',
                     input:     display,
                     framerate: 15.0,
                     advanced:  %w(let me fool you) }
        expect { FFMPEG::RecorderOptions.new(bad_opts) }.to raise_exception(ArgumentError)
      end
    end

    describe '#framerate' do
      let(:opts) do
        { input:     display,
          output:    'recorder-output.mkv',
          framerate: 30.0 }
      end

      it 'returns user given framerate value' do
        expect(recorder_options.framerate).to eql(opts[:framerate])
      end
    end
  end

  describe '#log_level' do
    it 'returns user given log level for the gem' do
      expect(recorder_options.log_level).to eql(opts[:log_level])
    end
  end

  describe '#all' do
    it 'returns Hash of all suer given options' do
      expect(recorder_options.all).to eql(opts)
    end
  end

  describe '#parsed' do
    let(:expected_parsed_valued) {
      "-f #{os_specific_format} -r #{opts[:framerate]} -loglevel #{opts[:advanced][:loglevel]}" + \
      " -video_size #{opts[:advanced][:video_size]} -show_region #{opts[:advanced][:show_region]}" + \
      " -i #{opts[:input]} #{opts[:output]} 2> ffmpeg.log"
    }

    it 'returns parsed options ready for FFmpeg to receive' do
      expect(recorder_options.parsed).to eql(expected_parsed_valued)
    end
  end
end