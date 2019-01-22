require_relative '../spec_helper'

#
# Windows Only
#
if OS.windows? # Only gdigrab supports window capture
  RSpec.describe FFMPEG::RecordingRegions do
    describe '#fetch' do
      let(:browser_process) {
        'firefox'
      }

      let(:browser) do
        Webdrivers.install_dir = 'webdrivers_bin'
        Watir::Browser.new :firefox
      end

      let(:url) {
        'https://google.com'
      }

      let(:expected_title) {
        ['Google - Mozilla Firefox']
      }

      it 'returns window title from Mozilla Firefox' do
        # Note: browser is lazily loaded with let
        browser.goto url
        browser.wait
        expect(FFMPEG::RecordingRegions.fetch(browser_process)).to eql(expected_title)
        browser.quit
      end
    end # describe
  end # Os.windows?
end