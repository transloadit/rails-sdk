$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

# require 'simplecov'
# 
# SimpleCov.start { add_filter '/test/' }

require 'transloadit/rails'

require 'rails/test_help'
require 'rails/generators/test_case'
