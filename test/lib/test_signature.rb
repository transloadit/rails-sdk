require "test_helper"
require "ostruct"

class SignatureTest < ActiveSupport::TestCase
  test "engine sign returns sha384-prefixed signature" do
    params = '{"auth":{"key":"test-key"}}'
    secret = "test-secret"

    expected = "sha384:#{Transloadit::Request.send(:_hmac, secret, params)}"

    Transloadit::Rails::Engine.stub(:transloadit, OpenStruct.new(secret: secret)) do
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

    Transloadit::Rails::Engine.stub(:configuration, config) do
      Transloadit::Rails::Engine.stub(:template, template) do
        html = helper.transloadit(:any)
        assert_includes html, 'name="signature"'
        assert_match(/value="sha384:[a-f0-9]+"/, html)
      end
    end
  end
end
