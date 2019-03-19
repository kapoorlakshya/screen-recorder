require_relative '../spec_helper'

RSpec.describe ScreenRecorder::Options do
  let(:display) {
    if OS.linux?
      `echo $DISPLAY`.strip || ':0.0' # If $DISPLAY is not set, use default of :0.0
    elsif OS.mac?
      '1'
    elsif OS.windows?
      'desktop'
    else
      raise NotImplementedError, 'Your OS is not supported.'
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
    ScreenRecorder::Options.new(opts)
  }

  describe 'new' do
    it '#accepts a Hash' do
      expect { ScreenRecorder::Options.new(opts) }.to_not raise_exception # ArgumentError
    end

    it 'raise ArgumentError if user provides an object other than a Hash' do
      expect { ScreenRecorder::Options.new([]) }.to raise_exception(ArgumentError)
    end

    it 'raises an error when a required option (ex: output) is not provided' do
      expect { ScreenRecorder::Options.new({ input: display, }) }.to raise_exception(ArgumentError)
    end
  end

  describe '#capture_device' do
    it 'returns capture device based on current OS' do
      expect(recorder_options.capture_device).to eql(os_specific_format)
    end
  end

  describe '#framerate' do
    it 'returns default framerate value' do
      expect(recorder_options.framerate).to eql(ScreenRecorder::Options::DEFAULT_FPS)
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
        bad_opts = { output:   'recorder-output.mkv',
                     input:    display,
                     advanced: %w(let me fool you) }
        expect { ScreenRecorder::Options.new(bad_opts) }.to raise_exception(ArgumentError)
      end
    end

    describe '#framerate' do
      let(:opts) do
        { input:    display,
          output:   'recorder-output.mkv',
          advanced: { framerate: 30.0 }
        }
      end

      it 'returns user given framerate value' do
        expect(ScreenRecorder::Options.new(opts).framerate).to eql(opts[:advanced][:framerate])
      end
    end
  end

  describe '#log' do
    context 'user given log filename' do
      let(:opts) do
        { input:    display,
          output:   'recorder-output.mkv',
          advanced: { log: 'recorder.log' }
        }
      end

      it 'returns user given log filename' do
        expect(ScreenRecorder::Options.new(opts).log).to eql(opts[:advanced][:log])
      end
    end

    context 'default log filename' do
      let(:opts) do
        { input:    display,
          output:   'recorder-output.mkv',
        }
      end

      it 'returns user given log filename' do
        expect(ScreenRecorder::Options.new(opts).log).to eql(ScreenRecorder::Options::DEFAULT_LOG_FILE)
      end
    end
  end

  describe '#all' do
    it 'returns Hash of all user given options' do
      expect(recorder_options.all).to eql(opts)
    end
  end

  describe '#parsed' do
    let(:opts) do
      { input:     display,
        output:    'recorder-output.mkv',
        log_level: Logger::INFO,
        advanced:  { framerate: 30.0,
                     loglevel:  'level+debug', # For FFmpeg
                     video_size:  '640x480',
                     show_region: '1' } }
    end

    let(:expected_parsed_valued) {
      "-f #{os_specific_format} -framerate #{opts[:advanced][:framerate]} -loglevel #{opts[:advanced][:loglevel]}" + \
      " -video_size #{opts[:advanced][:video_size]} -show_region #{opts[:advanced][:show_region]}" + \
      " -i #{opts[:input]} #{opts[:output]} 2> ffmpeg.log"
    }

    it 'returns parsed options ready for FFmpeg to receive' do
      expect(ScreenRecorder::Options.new(opts).parsed).to eql(expected_parsed_valued)
    end
  end
end