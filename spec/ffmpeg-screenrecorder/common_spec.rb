RSpec.describe ScreenRecorder::Common do
  context 'given the gem is loaded' do
    it 'has a version number' do
      expect(ScreenRecorder::VERSION).not_to be nil
    end

    it 'it can find the FFmpeg binary' do
      # noinspection RubyResolve
      expect(`#{FFMPEG.ffmpeg_binary} -version`).to include('ffmpeg version')
    end
  end
end