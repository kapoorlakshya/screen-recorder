require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-performance'
end

RSpec::Core::RakeTask.new(:spec)

task default: %w[spec rubocop]