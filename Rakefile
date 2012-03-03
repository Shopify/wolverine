require "bundler/gem_tasks"

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

require 'yard'
require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new do |yardoc|
  yardoc.options = ['--verbose', '--markup', 'markdown']
  # yardoc.files = [
  #   'lib/**/*.rb', 'README.md', 'CHANGELOG.md', 'LICENSE'
  # ]
end

task default: :test
