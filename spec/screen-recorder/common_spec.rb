RSpec.describe ScreenRecorder::Common do
  context 'given the gem is loaded' do
    it 'has a version number' do
      expect(ScreenRecorder::VERSION).not_to be nil
    end

    it 'it can find the FFmpeg binary' do
      # noinspection RubyResolve
      expect(`#{ScreenRecorder.ffmpeg_binary} -version`).to include('ffmpeg version')
    end

    it 'can defaults the logging level to :ERROR' do
      ScreenRecorder.logger.level = :ERROR
      expect(ScreenRecorder.logger.level).to eq(3)
    end

    it 'can change the logging level to :DEBUG' do
      ScreenRecorder.logger.level = :DEBUG
      expect(ScreenRecorder.logger.level).to eq(0)
    end
  end
end