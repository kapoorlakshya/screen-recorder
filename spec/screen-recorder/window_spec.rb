# Only gdigrab supports window capture
RSpec.describe ScreenRecorder::Window, if: OS.windows? do
  let(:test_website) { 'https://google.com' }

  it 'raises an error when a title is not given' do
    # noinspection RubyArgCount
    expect { described_class.new(output: test_output) }.to raise_error(ArgumentError)
  end

  context 'when using Firefox' do
    let!(:browser) { Watir::Browser.new :firefox }
    let(:page_title) { ScreenRecorder::Titles.fetch('firefox').first }
    let(:recorder) { described_class.new(title: page_title, output: test_output) }

    after { browser.quit }

    it 'can record a specific window with given title' do
      browser.goto 'watir.com'
      recorder.start
      sleep(1.0)
      recorder.stop

      expect(recorder.options.all[:input]).to include('Watir Project')
      expect(File).to exist(recorder.options.output)
      expect(recorder.video.valid?).to be(true)
    end
  end

  context 'when using Chrome' do
    let!(:browser) { Watir::Browser.new :chrome, options: { args: ['--disable-gpu'] } }
    let(:page_title) { ScreenRecorder::Titles.fetch('chrome').first }
    let(:recorder) { described_class.new(title: page_title, output: test_output) }

    after { browser.quit }

    it 'can record a specific window with given title' do
      browser.goto 'watir.com'
      recorder.start
      sleep(1.0)
      recorder.stop

      expect(recorder.options.all[:input]).to include('Watir Project')
      expect(File).to exist(recorder.options.output)
      expect(recorder.video.valid?).to be(true)
    end
  end

  describe '#screenshot' do
    let!(:browser) { Watir::Browser.new :chrome, options: { args: ['--disable-gpu'] } }
    let(:page_title) { ScreenRecorder::Titles.fetch('chrome').first }
    let(:recorder) { described_class.new(title: page_title, output: test_output) }
    let(:image_file) { 'screenshot.png' }

    before do
      browser.goto 'watir.com'
    end

    after do
      browser.quit
      delete_file(image_file)
    end

    it 'can take a screenshot when a video is not being recorded' do
      recorder.screenshot(image_file)
      expect(File).to exist(image_file)
    end

    it 'can take a screenshot when a video is being recorded' do
      recorder.start
      recorder.screenshot(image_file)
      recorder.stop
      expect(File).to exist(image_file)
    end
  end
end # describe