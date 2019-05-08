RSpec.describe ScreenRecorder::Titles do
  describe '.fetch' do
    context 'when the user is using Linux or MacOS', if: OS.linux? || OS.mac? do
      it 'raises error when OS is not Microsoft Windows' do
        # @todo Raise StandardError instead.
        expect { described_class.fetch('firefox') }.to raise_error(NotImplementedError)
      end
    end
  end

  context 'when the given application is Firefox', if: OS.windows? do
    let(:browser_process) { :firefox }
    let(:url) { 'https://google.com' }
    let(:expected_title) { 'Google - Mozilla Firefox' }
    let(:browser) do
      Webdrivers.install_dir = 'webdrivers_bin'
      Watir::Browser.new browser_process
    end

    before do
      # Note: browser is lazily loaded with let
      browser.goto url
      browser.wait
    end

    after do
      browser.quit
    end

    it 'returns a list of available windows from firefox' do
      browser.wait
      expect(described_class.fetch('firefox')).to be_a_kind_of(Array)
    end

    it 'does not return an empty list' do
      browser.wait
      expect(described_class.fetch('firefox').empty?).to be(false)
    end

    it 'returns window title from Mozilla Firefox' do
      expect(described_class.fetch(browser_process).first).to eql(expected_title)
    end
  end

  context 'when a firefox window is not open', if: OS.windows? do
    it 'raises an exception' do
      expect { described_class.fetch('firefox') }.to raise_exception(ScreenRecorder::Errors::ApplicationNotFound)
    end
  end

  context 'when application is Chrome with extensions as individual processes', if: OS.windows? do
    let(:browser_process) { :chrome }
    let(:url) { 'https://google.com' }
    let(:expected_titles) { ['Google - Google Chrome'] }
    let(:browser) do
      Webdrivers.install_dir = 'webdrivers_bin'
      Watir::Browser.new browser_process
    end

    before do
      # Note: browser is lazily loaded with let
      browser.goto url
      browser.wait
    end

    after do
      browser.quit
    end

    it 'excludes titles from extensions' do
      expect(described_class.fetch(browser_process)).to eql(expected_titles)
    end
  end
end # RSpec.describe