require_relative '../spec_helper'

RSpec.describe FFMPEG::RecorderOptions do
  describe 'new' do
    it '#accepts a Hash' do

    end

    it 'raise ArgumentError if user provides an object other than a Hash' do
      expect { FFMPEG::RecorderOptions.new([]) }.to raise_exception(ArgumentError)
    end

    it 'raises an error when required options are not provided' do
      expect { FFMPEG::RecorderOptions.new({}) }.to raise_exception(ArgumentError)
    end
  end

  describe '#format' do
    it 'returns device format based on current OS' do
      expected_format = if OS.windows?
                          'gdigrab'
                        elsif OS.linux?
                          'x11grab'
                        elsif OS.mac?
                          'avfoundation'
                        else
                          raise NotImplementedError, 'Your OS is not supported.'
                        end
      expect(options.format).to eql(expected_format)
    end
  end

  describe '#framerate' do
    it 'returns user given framerate value' do

    end
  end

  describe '#input' do
    it 'returns user given input value' do

    end
  end

  describe '#output' do
    it 'returns user given output value' do

    end
  end

  context 'user wants to provide advanced options' do
    describe '#advanced' do
      it 'returns Hash of advanced options' do

      end

      it 'raise ArgumentError if user provides an object other than a Hash' do

      end
    end
  end

  describe '#log_level' do
    it 'returns user given log level for the gem' do

    end
  end

  describe '#all' do
    it 'returns Hash of all suer given options' do

    end
  end

  describe '#parsed' do
    it 'returns parsed options ready for FFmpeg to receive' do

    end
  end

end