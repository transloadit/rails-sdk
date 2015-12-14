$:.unshift File.dirname(__FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'minitest/autorun'
require 'transloadit/rails'

require 'rails/test_help'
require 'rails/generators/test_case'
