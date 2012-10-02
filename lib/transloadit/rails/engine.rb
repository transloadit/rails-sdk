require 'transloadit/rails'
require 'transloadit/generators'
require 'rails'

class Transloadit
  module Rails
    autoload :ParamsDecoder, 'transloadit/rails/params_decoder'
    autoload :ViewHelper,    'transloadit/rails/view_helper'

    class Engine < ::Rails::Engine
      CONFIG_PATH = 'config/transloadit.yml'

      initializer 'transloadit-rails.action_controller' do |app|
        ActiveSupport.on_load :action_controller do
          helper TransloaditHelper
        end
      end

      initializer 'transloadit-rails.action_view' do |app|
        ActiveSupport.on_load :action_view do
          include Transloadit::Rails::ViewHelper
        end
      end

      initializer 'transloadit.configure' do |app|
        self.class.application = app
      end

      class << self
        attr_accessor :application
      end

      #
      # Returns the configuration object (read from the YAML config file)
      #
      def self.configuration
        if !@configuration || ::Rails.env.development?
          path           = self.application.root.join(CONFIG_PATH)
          erb            = ERB.new(path.read)
          erb.filename   = path.to_s
          @configuration = YAML.load(erb.result)
        end

        if @configuration.keys.include?(::Rails.env)
          @configuration = @configuration[::Rails.env]
        end

        @configuration
      end

      #
      # Returns the Transloadit authentication object.
      #
      def self.transloadit
        Transloadit.new(
          :key      => self.configuration['auth']['key'],
          :secret   => self.configuration['auth']['secret'],
          :duration => self.configuration['auth']['duration']
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
  end
end
