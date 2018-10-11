RSpec.describe FFMPEG::Screenrecorder do
  it 'has a version number' do
    expect(FFMPEG::Screenrecorder::VERSION).not_to be nil
  end

  it 'it can find the FFMPEG binary' do
    expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
  end
end
