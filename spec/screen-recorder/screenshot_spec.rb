RSpec.describe 'ScreenRecorder::Screenshot' do
  describe '.screenshot' do
    let(:recorder) { ScreenRecorder::Desktop.new(input: test_input, output: test_output) }
    let(:image_file) { "#{Dir.pwd}/screenshot-#{Time.now.to_i}.png" }

    context 'when recording a desktop' do
      it 'can take a screenshot' do
        recorder.start
        file = recorder.screenshot(image_file)
        recorder.stop

        expect(file).to eq(image_file)
        expect(File).to exist(file)
      end
    end

    context 'when video is not being recorded' do
      it 'can take a screenshot' do
        file = recorder.screenshot(image_file)
        expect(File).to exist(file)
      end
    end

    context 'when resolution is given' do
      let(:given_resolution) { '640x480' }

      it 'saves screenshot at given resolution' do
        recorder.screenshot(image_file, given_resolution)
        res = get_resolution(image_file)
        expect(res).to eql(given_resolution)
      end
    end
  end
end
