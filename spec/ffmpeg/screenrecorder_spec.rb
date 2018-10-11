RSpec.describe FFMPEG::Screenrecorder do
  before do
    @opts     = { output: 'C:\test-output.mkv' }
    @recorder = FFMPEG::Screenrecorder.new(@opts)
  end

  it 'has a version number' do
    expect(FFMPEG::Screenrecorder::VERSION).not_to be nil
  end

  it 'it can find the FFMPEG binary' do
    expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
  end

  it 'returns an IO object when #start is invoked' do

  end

  it 'returns 1 when #stop is invoked' do

  end

  it 'can record the desktop and output a file' do
    @recorder.start
    @recorder.stop
    expect(File).to exist(@opts[:output])
  end

  it 'can record at a given FPS of 15' do

  end

end
