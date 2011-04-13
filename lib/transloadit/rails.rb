require 'transloadit'
require 'transloadit/generators'
require 'rails'

class Transloadit::Rails < Rails::Engine
  CONFIG_PATH = 'config/transloadit.yml'
  
  autoload :FormHelper, 'transloadit/rails/form_helper'
  
  config.to_prepare do
    # add the two helpers to the view stack
    ApplicationController.helper TransloaditHelper
    
    class ActionView::Helpers::FormBuilder
      include Transloadit::Rails::FormHelper
    end
  end
  
  initializer 'transloadit.configure' do |app|
    # preload the contents of the configuration file.
    app.root.join(CONFIG_PATH).open do |file|
      self.class.config = YAML.load(file)
    end rescue nil
  end
  
  class << self
    attr_accessor :config
  end
  
  #
  # Returns the Transloadit authentication object.
  #
  def self.transloadit
    Transloadit.new(
      :key    => self.config['auth']['key'],
      :secret => self.config['auth']['secret']
    )
  end
  
  #
  # Creates an assembly for the named template.
  #
  def self.template(name, options = {})
    template = self.config['templates'].try(:fetch, name.to_s)
    
    self.transloadit.assembly case template
      when String then { :template_id => template }.merge(options)
      when Hash   then template                    .merge(options)
    end
  end
  
  #
  # Signs a request to the Transloadit API.
  #
  def self.sign(params)
    Transloadit::Request.send :_hmac, self.transloadit.secret, params
  end
end
