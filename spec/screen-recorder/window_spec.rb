# Only gdigrab supports window capture
RSpec.describe ScreenRecorder::Window, if: OS.windows? do
  let(:test_website) { 'https://google.com' }

  it 'raises an error when a title is not given' do
    # noinspection RubyArgCount
    expect { described_class.new(output: test_output) }.to raise_error(ArgumentError)
  end

  context 'when using Chrome' do
    let!(:browser) { Watir::Browser.new :chrome, options: { args: ['--disable-gpu'] } }
    let(:recorder) do
      page_title = described_class.fetch_title('chrome').first
      described_class.new(title: page_title, output: test_output)
    end

    before do
      browser.goto 'watir.com'
      browser.wait
    end

    after { browser.close }

    it 'can record a specific window with given title' do
      recorder.start
      sleep(1.0)
      recorder.stop

      aggregate_failures do
        expect(recorder.options.all[:input]).to include('Watir Project')
        expect(File).to exist(recorder.options.output)
        expect(recorder.video.valid?).to be(true)
      end
    end
  end
end