require_relative '../spec_helper'

if OS.windows? # Only gdigrab supports window capture
  RSpec.describe ScreenRecorder::Window do
    let(:browser) do
      Webdrivers.install_dir = 'webdrivers_bin'
      Watir::Browser.new :firefox
    end

    let(:recorder) { ScreenRecorder::Window.new(title: 'Mozilla Firefox', output: 'recording.mkv') }

    after do
      FileUtils.rm recorder.options.output if File.exist? recorder.options.output
      FileUtils.rm recorder.options.log if File.exist? recorder.options.log
    end

    it 'raises an error when a title is not given' do
      # noinspection RubyArgCount
      expect { ScreenRecorder::Window.new(output: 'recording.mkv') }.to raise_error(ArgumentError)
    end

    it 'can record a specific firefox window with given title' do
      # Note: browser is lazily loaded with let
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

    #
    # Clean up
    #
  end # describe
end # Os.windows?
