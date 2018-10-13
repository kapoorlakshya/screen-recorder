RSpec.describe FFMPEG::Screenrecorder do
  before do
    @opts     = { output:    'C:\ffmpeg-screenrecorder-rspec-output.mkv',
                  input:     'desktop',
                  framerate: 15 }
    @recorder = FFMPEG::Screenrecorder.new(@opts)
    @output   = FFMPEG::Movie.new(@opts[:output])
  end

  context 'given the gem is loaded' do
    it 'has a version number' do
      expect(FFMPEG::Screenrecorder::VERSION).not_to be nil
    end

    it 'it can find the FFMPEG binary' do
      expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
    end
  end

  context 'given the recorder has been initialized' do
    it 'returns an IO object when #start is invoked' do
      expect(@recorder.start(@opts)).to be_a_kind_of(IO)
    end

    it 'returns pid when #pid is invoked' do
      expect(@recorder.pid).to be_a_kind_of(Fixnum)
    end

    it 'returns 1 when #stop is invoked' do
      expect(@recorder.stop).to be(1)
    end

    it 'creates a file at the output path when #stop is invoked' do
      expect(File).to exist(@opts[:output])
    end

    it 'creates a valid video file when #stop is invoked' do
      @output.valid?
    end
  end

  context 'given the recorder accepts user defined options' do
    it 'can record the desktop as input' do
      @recorder.start(@opts)
      sleep(5.0)
      @recorder.stop
      expect(File).to exist(@opts[:output])
    end

    it 'can record at a user given FPS' do
      expect(@output.frame_rate).to equal(@opts[:framerate])
    end

    it 'can return a list of available inputs (recording regions)' do
      expect(@recorder.inputs).to be_a_kind_of(Array)
    end

    it 'can record a browser window' do
      browser = Watir::Browser.new :firefox
      browser.resize_to(800, 600)
      browser.goto 'google.com'
      inputs = FFMPEG::Screenrecorder.inputs # Tab with title as Google

      opts     = { output:    'C:\ffmpeg-screenrecorder-rspec-output.mkv',
                   input:     inputs.first,
                   framerate: 15 }
      recorder = FFMPEG::Screenrecorder.new(opts)
      recorder.start
      3.times { browser.refresh }
      recorder.stop

      # @todo Can't think of a valid test for this...
    end
  end
end
