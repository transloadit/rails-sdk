require "test_helper"
require "ostruct"

class SignatureTest < ActiveSupport::TestCase
  test "engine sign returns sha384-prefixed signature" do
    params = '{"auth":{"key":"test-key"}}'
    secret = "test-secret"

    expected = "sha384:#{Transloadit::Request.send(:_hmac, secret, params)}"

    with_engine_singleton_method(:transloadit, proc { |_options = {}| OpenStruct.new(secret: secret) }) do
      assert_equal expected, Transloadit::Rails::Engine.sign(params)
    end
  end

  test "view helper includes prefixed signature field" do
    params = '{"auth":{"key":"test-key"}}'

    helper = Object.new
    helper.extend(Transloadit::Rails::ViewHelper)
    helper.define_singleton_method(:hidden_field_tag) do |name, value, _opts|
      %(<input name="#{name}" value="#{value}">)
    end

    config = { "auth" => { "secret" => "test-secret" } }
    template = Struct.new(:json).new(params)

    with_engine_singleton_method(:configuration, proc { config }) do
      with_engine_singleton_method(:template, proc { |_name = nil, _options = {}| template }) do
        html = helper.transloadit(:any)
        assert_includes html, 'name="signature"'
        assert_match(/value="sha384:[a-f0-9]+"/, html)
      end
    end
  end

  private

  def with_engine_singleton_method(name, implementation)
    eigenclass = class << Transloadit::Rails::Engine
      self
    end

    backup = "__orig_#{name}_for_test__"
    had_method = eigenclass.method_defined?(name) || eigenclass.private_method_defined?(name)
    eigenclass.send(:alias_method, backup, name) if had_method

    Transloadit::Rails::Engine.define_singleton_method(name, &implementation)
    yield
  ensure
    eigenclass = class << Transloadit::Rails::Engine
      self
    end
    eigenclass.send(:remove_method, name) rescue nil
    if had_method
      eigenclass.send(:alias_method, name, backup)
      eigenclass.send(:remove_method, backup) rescue nil
    end
  end
end
