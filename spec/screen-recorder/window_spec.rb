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

    before do
      Webdrivers.install_dir = 'webdrivers_bin'
      Webdrivers.cache_time  = 86_400
    end

    it 'can record a specific window with given title' do
      browser.window.resize_to 1280, 720
      recorder.start
      browser.goto 'watir.com'
      browser.link(text: 'News').wait_until(&:present?).click
      browser.wait
      recorder.stop
      browser.quit

      expect(File).to exist(recorder.options.output)
      expect(recorder.video.valid?).to be(true)
    end
  end

  context 'when using Chrome' do
    let!(:browser) { Watir::Browser.new :chrome }
    let(:page_title) { ScreenRecorder::Titles.fetch('chrome').first }
    let(:recorder) { described_class.new(title: page_title, output: test_output) }

    before do
      Webdrivers.install_dir = 'webdrivers_bin'
      Webdrivers.cache_time  = 86_400
    end

    it 'can record a specific window with given title' do
      browser.window.resize_to 1280, 720
      recorder.start
      browser.goto 'watir.com'
      browser.link(text: 'News').wait_until(&:present?).click
      browser.wait
      recorder.stop
      browser.quit

      expect(File).to exist(recorder.options.output)
      expect(recorder.video.valid?).to be(true)
    end
  end
end # describe