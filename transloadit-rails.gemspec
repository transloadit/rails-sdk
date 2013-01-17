$:.unshift File.expand_path('../lib', __FILE__)

require 'transloadit/rails/version'

Gem::Specification.new do |gem|
  gem.name     = 'transloadit-rails'
  gem.version  = Transloadit::Rails::VERSION
  gem.platform = Gem::Platform::RUBY

  gem.authors  = ['Stephen Touset', 'Robin Mehner']
  gem.email    = ['stephen@touset.org', 'robin@coding-robin.de']
  gem.homepage = 'http://github.com/transloadit/rails-sdk/'

  gem.summary     = 'Official Rails gem for Transloadit'
  gem.description = 'The transloadit-rails gem allows you to automate uploading files through the Transloadit REST API'

  gem.required_rubygems_version = '>= 1.3.6'
  gem.rubyforge_project         = 'transloadit-rails'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_paths = %w{ lib }

  gem.add_dependency 'transloadit', '>= 1.0.2'
  gem.add_dependency 'railties',    '>= 3'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest' # needed for < 1.9.2
  gem.add_development_dependency 'simplecov'

  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rdiscount' # for YARD rdoc formatting
end
