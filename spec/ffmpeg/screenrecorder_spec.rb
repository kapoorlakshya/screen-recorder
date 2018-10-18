require_relative '../spec_helper'

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
      opts      = { output:     'ffmpeg-screenrecorder-rspec-output.mkv',
                    input:      'desktop',
                    framerate:  30.0,
                    extra_opts: { video_size: '1024x768' } }
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
      duration = 10.0
      puts "\tWaiting #{duration}s for recording to complete..."
      sleep(duration) # Takes 10s to create a valid recording
      expect(@recorder.stop).to include('SUCCESS')
    end

    it 'creates a output file when #stop is invoked' do
      expect(File).to exist(@recorder.output)
    end

    it 'creates a valid video file when #stop is invoked' do
      expect(@recorder.video_file.valid?).to be(true)
    end

    it 'can record at a user given FPS' do
      expect(@recorder.video_file.frame_rate).to equal(@recorder.opts[:framerate])
    end

    it 'uses recording resolution from extra_opts' do
      expect(@recorder.video_file.resolution).to eq(@recorder.opts[:extra_opts][:video_size])
    end

    it 'can return a list of available inputs (recording regions)' do
      app     = :firefox
      browser = Watir::Browser.new app
      browser.goto 'google.com'
      expect(@recorder.inputs(app)).to be_a_kind_of(Array)
      browser.quit
    end

    # it 'can record a browser window' do
    #   browser = Watir::Browser.new :firefox
    #   browser.resize_to(800, 600)
    #   browser.goto 'google.com'
    #   inputs = FFMPEG::Recorder.inputs # Tab with title as Google
    #
    #   opts     = { output:    'C:\ffmpeg-screenrecorder-rspec-output.mkv',
    #                input:     inputs.first,
    #                framerate: 15 }
    #   recorder = FFMPEG::Screenrecorder.new(opts)
    #   recorder.start
    #   3.times { browser.refresh }
    #   recorder.stop
    #
    #   # @todo Can't think of a valid test for this...
    # end

    #
    # Clean up
    #
    after(:all) do
      `rm #{@recorder.output}`
      sleep(0.5)
      `rm #{@recorder.opts[:log]}`
    end
  end
end