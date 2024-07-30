lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'screen-recorder/version'

Gem::Specification.new do |spec|
  spec.name                  = 'screen-recorder'
  spec.version               = ScreenRecorder::VERSION
  spec.required_ruby_version = '>= 2.0.0'
  spec.authors               = ['Lakshya Kapoor']
  spec.email                 = ['kapoorlakshya@gmail.com']
  spec.homepage              = 'http://github.com/kapoorlakshya/screen-recorder'
  spec.summary               = 'Video record and take screenshots your computer screen using FFmpeg.'
  spec.description           = 'A Ruby gem to video record and take screenshots of your desktop or  ' \
                               'specific application window. Works on Windows, Linux, and macOS.'
  spec.license               = 'MIT'
  # noinspection RubyStringKeysInHashInspection
  spec.metadata              = {
    'changelog_uri' => 'https://github.com/kapoorlakshya/screen-recorder/blob/master/CHANGELOG.md',
    'source_code_uri' => "https://github.com/kapoorlakshya/screen-recorder/tree/v#{ScreenRecorder::VERSION}",
    'documentation_uri' => "https://www.rubydoc.info/gems/screen-recorder/#{ScreenRecorder::VERSION}",
    'bug_tracker_uri' => 'https://github.com/kapoorlakshya/screen-recorder/issues',
    'wiki_uri' => 'https://github.com/kapoorlakshya/screen-recorder/wiki',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_dependency 'streamio-ffmpeg', '~> 3.0'
end
