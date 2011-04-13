require 'transloadit/rails'
require 'rails/generators'

class Transloadit::Generators::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../../../templates/transloadit', __FILE__)
  
  desc %{Installs an empty Transloadit config file}
  
  def copy_configuration
    template 'transloadit.yml', 'config/transloadit.yml'
  end
end
