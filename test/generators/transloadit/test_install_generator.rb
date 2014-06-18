require 'action_controller'
require 'test_helper'

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Transloadit::Generators::InstallGenerator
  destination File.expand_path('../../../tmp', __FILE__)

  setup do
    prepare_destination
  end

  test 'the Transloadit config file is installed' do
    run_generator

    assert_file 'config/transloadit.yml' do |contents|
      assert_match /auth/,      contents
      assert_match /templates/, contents
    end
  end

  test 'the namespace is transloadit:install' do
    assert_equal 'transloadit:install', generator_class.namespace
  end
end
