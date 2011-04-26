require 'transloadit'
require 'transloadit/generators'
require 'rails'

class Transloadit::Rails < Rails::Engine
  CONFIG_PATH = 'config/transloadit.yml'
  
  autoload :ControllerExtensions, 'transloadit/rails/controller_extensions'
  autoload :FormHelper,           'transloadit/rails/form_helper'
  
  config.to_prepare do
    # add the two helpers to the view stack
    class ActionController::Base
      include Transloadit::Rails::ControllerExtensions
      helper TransloaditHelper
    end
    
    class ActionView::Helpers::FormBuilder
      include Transloadit::Rails::FormHelper
    end
  end
  
  initializer 'transloadit.configure' do |app|
    self.class.application = app
  end
  
  def self.configuration
    YAML.load_file self.application.root.join(CONFIG_PATH)
  end
  
  class << self
    attr_accessor :application
    
    extend ActiveSupport::Memoizable
    memoize :configuration unless Rails.env.development?
  end
  
  #
  # Returns the Transloadit authentication object.
  #
  def self.transloadit
    Transloadit.new(
      :key    => self.configuration['auth']['key'],
      :secret => self.configuration['auth']['secret']
    )
  end
  
  #
  # Creates an assembly for the named template.
  #
  def self.template(name, options = {})
    template = self.configuration['templates'].try(:fetch, name.to_s)
    
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
