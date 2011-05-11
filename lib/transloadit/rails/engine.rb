require 'transloadit/rails'
require 'transloadit/generators'
require 'rails'

class Transloadit
  module Rails
    class Engine < ::Rails::Engine
      CONFIG_PATH = 'config/transloadit.yml'

      initializer 'transloadit-rails.action_controller' do |app|
        ActiveSupport.on_load :action_controller do
          helper TransloaditHelper
        end
      end

      initializer 'transloadit-rails.action_view' do |app|
        ActiveSupport.on_load :action_view do
          require 'transloadit/rails/view_helper'
          include Transloadit::Rails::ViewHelper
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
        memoize :configuration unless ::Rails.env.development?
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
  end
end
