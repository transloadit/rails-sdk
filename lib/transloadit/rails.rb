require 'transloadit'
require 'transloadit/generators'
require 'rails'

class Transloadit::Rails < Rails::Engine
  autoload :FormHelper, 'transloadit/rails/form_helper'
  
  config.to_prepare do
    ApplicationController.helper TransloaditHelper
    ActionView::Helpers::FormBuilder include Transloadit::Rails::FormHelper
  end
  
  initializer 'transloadit.configure' do |app|
    app.root.join('config/transloadit.yml').open do |file|
      self.class.config = YAML.load(file)
    end
  end
  
  class << self
    attr_accessor :config
  end
  
  def self.transloadit
    Transloadit.new(
      :key    => self.config['auth']['key'],
      :secret => self.config['auth']['secret']
    )
  end
  
  def self.template(name, options = {})
    template = self.config['templates'][name]
    
    self.transloadit.assembly case template
      when String then { :template => template }.merge(options)
      when Hash   then template                 .merge(options)
    end
  end
  
  def self.sign(params)
    Transloadit::Request.send :_hmac, self.transloadit.secret, params
  end
end
