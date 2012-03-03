require "bundler/gem_tasks"

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

require 'yard'
require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new do |yardoc|
  yardoc.options = ['--verbose']
  # yardoc.files = [
  #   'lib/**/*.rb', 'README.md', 'CHANGELOG.md', 'LICENSE'
  # ]
end

task :docs do
  Rake::Task['yard'].invoke
  system("cd doc && git add . && git commit -am 'Regenerated docs' && git push origin gh-pages")
end

task default: :test
