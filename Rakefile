require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs = ['lib', 'test']
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
