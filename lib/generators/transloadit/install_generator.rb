require 'transloadit/rails'
require 'rails/generators'

class Transloadit::Rails::Generators::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../../templates/transloadit', __FILE__)
  
  desc %{Installs the Transloadit jQuery plugin and creates the config file}
  
  def copy_configuration
    template 'transloadit.yml', 'config/transloadit.yml'
  end
  
  def copy_jquery_plugin
    get 'http://assets.transloadit.com/js/jquery.transloadit2.js',
      'public/javascripts/jquery.transloadit2.js'
  end
end
