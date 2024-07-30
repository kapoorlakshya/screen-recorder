RSpec.describe ScreenRecorder::Titles do
  describe '.fetch' do
    context 'when the user is using Linux or MacOS', if: ScreenRecorder::OS.linux? || ScreenRecorder::OS.mac? do
      it 'raises error when OS is not Microsoft Windows' do
        # @todo Raise StandardError instead.
        expect { described_class.fetch('firefox') }.to raise_error(NotImplementedError)
      end
    end
  end

  context 'when the given application is a browser', if: ScreenRecorder::OS.windows? do
    let(:browser_process) { :firefox }
    let(:url) { 'https://google.com' }
    let(:expected_title) { 'Google — Mozilla Firefox' }
    let(:browser) do
      Watir::Browser.new browser_process, options: { args: ['--disable-gpu'] }
    end

    before do
      browser.goto url
      browser.wait
    end

    after do
      browser.close
    end

    it 'returns a list of available windows from firefox' do
      browser.wait
      expect(described_class.fetch('firefox')).to be_a(Array)
    end

    it 'does not return an empty list' do
      browser.wait
      expect(described_class.fetch('firefox').empty?).to be(false)
    end

    it 'returns window title from browser' do
      expect(described_class.fetch(browser_process).first).to eql(expected_title)
    end
  end

  context 'when a browser window is not open', if: ScreenRecorder::OS.windows? do
    it 'raises an exception' do
      expect { described_class.fetch('firefox') }.to raise_exception(ScreenRecorder::Errors::ApplicationNotFound)
    end
  end

  context 'when application is a browser with extensions as individual processes', if: ScreenRecorder::OS.windows? do
    let(:browser_process) { :firefox }
    let(:url) { 'https://google.com' }
    let(:expected_titles) { ['Google — Mozilla Firefox'] }
    let(:browser) do
      Watir::Browser.new browser_process
    end

    before do
      browser.goto url
      browser.wait
    end

    after do
      browser.close
    end

    it 'excludes titles from extensions' do
      expect(described_class.fetch(browser_process)).to eql(expected_titles)
    end
  end
end
