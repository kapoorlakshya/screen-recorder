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
  spec.summary               = 'Record your computer screen using FFmpeg via Ruby.'
  spec.description           = 'Record your computer screen - desktop or specific window - using FFmpeg (https://www.ffmpeg.org).'
  spec.license               = 'MIT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.59'
  spec.add_development_dependency 'rubocop-performance', '~> 1.1.0'
  spec.add_development_dependency 'rubocop-rspec', '~>1.32'
  spec.add_development_dependency 'simplecov', '~>0.16'
  spec.add_development_dependency 'watir', '~> 6.0'
  spec.add_development_dependency 'webdrivers', '~> 3.0'

  spec.add_runtime_dependency 'os', '~> 0.9.0'
  spec.add_runtime_dependency 'streamio-ffmpeg', '~> 3.0'
end
