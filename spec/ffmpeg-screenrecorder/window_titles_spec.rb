require_relative '../spec_helper'

#
# Windows Only
#
if OS.windows? # Only gdigrab supports window capture
  RSpec.describe FFMPEG::WindowTitles do
    describe '.fetch' do
      context 'given application is Firefox' do
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

        it 'returns a list of available windows from firefox' do
          browser.wait
          expect(FFMPEG::WindowTitles.fetch('firefox')).to be_a_kind_of(Array)
        end

        it 'does not return an empty list' do
          browser.wait
          expect(FFMPEG::WindowTitles.fetch('firefox').empty?).to be(false)
        end

        it 'returns window title from Mozilla Firefox' do
          expect(FFMPEG::WindowTitles.fetch(browser_process).first).to eql(expected_title)
        end

        after do
          browser.quit
        end
      end

      context 'given a firefox window is not open' do
        it 'raises an exception' do
          expect { FFMPEG::WindowTitles.fetch('firefox') }.to raise_exception(FFMPEG::RecorderErrors::ApplicationNotFound)
        end
      end

      context 'given application is Chrome with extensions as individual processes' do
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

        it 'excludes titles from extensions' do
          expect(FFMPEG::WindowTitles.fetch(browser_process)).to eql(expected_titles)
        end

        after do
          browser.quit
        end
      end
    end # describe
  end # RSpec.describe
end # Os.windows?