require 'rubygems/package_task'
require 'rake/testtask'

RUBIES = %w{ 1.9.2 1.8.7 1.8.6 rbx-1.2.0 }

GEMSPEC = 'transloadit-rails.gemspec'

spec = eval open(GEMSPEC).read
Gem::PackageTask.new(spec) do |gem|
  gem.need_tar = true
end

Rake::TestTask.new do |test|
  test.libs   << 'test'
  test.pattern = 'test/**/test_*.rb'
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  
  YARD::Rake::YardocTask.new :doc do |yard|
    yard.options = %w{
      --title  Transloadit Rails
      --readme README.md
      --markup rdoc
    }
  end
rescue
  desc 'You need the `yard` gem to generate documentation'
  task :doc
end
