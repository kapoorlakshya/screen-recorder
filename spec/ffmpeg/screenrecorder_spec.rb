require 'spec_helper'

RSpec.describe FFMPEG::Screenrecorder do
  context 'given the gem is loaded' do
    it 'has a version number' do
      expect(FFMPEG::Screenrecorder::VERSION).not_to be nil
    end

    it 'it can find the FFMPEG binary' do
      expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
    end
  end
end

RSpec.describe FFMPEG::Recorder do
  context 'given the recorder has been initialized' do
    before(:all) do
      opts      = { output:    'ffmpeg-screenrecorder-rspec-output.mkv',
                    input:     'desktop',
                    framerate: 15 }
      @recorder = FFMPEG::Recorder.new(opts)
    end

    it 'returns a Hash for #opts' do
      expect(@recorder.opts).to be_a(Hash)
    end

    it 'returns pid on #start' do
      pid = @recorder.start
      expect(pid).to be_a_kind_of(Integer)
    end

    it 'creates a log file on #start' do
      sleep(1.0) # Wait for file generation
      expect(File).to exist(@recorder.opts[:log])
    end

    it 'returns a SUCCESS message on #stop ' do
      sleep(10.0)
      expect(@recorder.stop).to include('SUCCESS')
    end

    it 'creates a output file when #stop is invoked' do
      expect(File).to exist(@recorder.opts[:output])
    end

    it 'creates a valid video file when #stop is invoked' do
      expect(FFMPEG::Movie.new(@recorder.opts[:output]).valid?).to be(true)
    end

    #
    # Clean up
    #
    after(:all) do
      `rm #{@recorder.opts[:output]}`
      sleep(0.5)
      `rm #{@recorder.opts[:log]}`
    end
  end
end

# context 'given the recorder accepts user defined options' do
#   it 'can record the desktop as input' do
#     @recorder.start
#     sleep(5.0)
#     @recorder.stop
#     expect(File).to exist(@opts[:output])
#   end
#
#   it 'can record at a user given FPS' do
#     expect(@output.frame_rate).to equal(@opts[:framerate])
#   end
#
#   it 'can return a list of available inputs (recording regions)' do
#     expect(@recorder.inputs).to be_a_kind_of(Array)
#   end
#
#   it 'can record a browser window' do
#     browser = Watir::Browser.new :firefox
#     browser.resize_to(800, 600)
#     browser.goto 'google.com'
#     inputs = FFMPEG::Recorder.inputs # Tab with title as Google
#
#     opts     = { output:    'C:\ffmpeg-screenrecorder-rspec-output.mkv',
#                  input:     inputs.first,
#                  framerate: 15 }
#     recorder = FFMPEG::Screenrecorder.new(opts)
#     recorder.start
#     3.times { browser.refresh }
#     recorder.stop
#
#     # @todo Can't think of a valid test for this...
#   end
# end
# end