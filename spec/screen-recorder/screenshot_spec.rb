RSpec.describe 'ScreenRecorder::Screenshot' do
  describe '.screenshot' do
    let(:recorder) { ScreenRecorder::Desktop.new(input: test_input, output: test_output) }
    let(:image_file) { 'screenshot.png' }

    after { delete_file(image_file) }

    context 'when recording a desktop' do
      it 'can take a screenshot' do
        recorder.start
        recorder.screenshot(image_file)
        recorder.stop
        expect(File).to exist(image_file)
      end
    end

    context 'when video is not being recorded' do
      it 'can take a screenshot' do
        recorder.screenshot(image_file)
        expect(File).to exist(image_file)
      end
    end

    context 'when resolution is given' do
      let(:given_resolution) { '1024x768' }

      it 'saves screenshot at given resolution' do
        recorder.screenshot(image_file, given_resolution)
        res = get_resolution(image_file)
        expect(res).to eql(given_resolution)
      end
    end

    context 'when recording a window', if: OS.windows? do
      let!(:browser) { Watir::Browser.new :chrome, options: { args: ['--disable-gpu'] } }
      let(:recorder) do
        page_title = ScreenRecorder::Window.fetch_title('chrome').first
        ScreenRecorder::Window.new(title: page_title, output: test_output)
      end
      let(:image_file) { 'screenshot.png' }

      before { browser.goto 'watir.com' }

      after { browser.close }

      it 'can take a screenshot' do
        recorder.start
        recorder.screenshot(image_file)
        recorder.stop
        expect(File).to exist(image_file)
      end
    end
  end
end
