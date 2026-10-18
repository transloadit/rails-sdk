require "test_helper"
require "json"
require "openssl"
require "ostruct"

class NotificationVerifierTest < ActiveSupport::TestCase
  PAYLOAD = "{\n  \"ok\": \"ASSEMBLY_COMPLETED\", \"assembly_id\": \"assembly-id\"\n}"
  SECRET = "notification-secret"

  # Stands in for an ActionController::Base subclass: records callbacks and responses.
  class FakeController
    class << self
      attr_reader :callbacks

      def before_action(name)
        (@callbacks ||= []) << name
      end
    end

    attr_accessor :client, :params, :request
    attr_reader :response_status

    def initialize(request_parameters)
      @request = OpenStruct.new(request_parameters: request_parameters)
      @params = ActiveSupport::HashWithIndifferentAccess.new(request_parameters)
    end

    def head(status)
      @response_status = status
    end

    def run_callbacks
      self.class.callbacks.each do |callback|
        send(callback)
        break if response_status
      end
    end
  end

  class VerifyingController < FakeController
    include Transloadit::Rails::NotificationVerifier

    def transloadit_notification_client
      client
    end
  end

  # ParamsDecoder first, so verification has to work on the raw form fields.
  class DecodingController < FakeController
    include Transloadit::Rails::ParamsDecoder
    include Transloadit::Rails::NotificationVerifier

    def transloadit_notification_client
      client
    end
  end

  # Mirrors Transloadit#verify_notification! for transloadit gems that predate it.
  class FakeClient
    attr_reader :received

    def verify_notification!(fields)
      @received = fields
      raise Transloadit::Exception::InvalidSignature unless fields["signature"] == "valid"

      JSON.parse(fields["transloadit"])
    end
  end

  setup do
    unless defined?(Transloadit::Exception::InvalidSignature)
      Transloadit::Exception.const_set(:InvalidSignature, Class.new(StandardError))
      @defined_invalid_signature = true
    end
  end

  teardown do
    Transloadit::Exception.send(:remove_const, :InvalidSignature) if @defined_invalid_signature
  end

  test "registers verification as a before action" do
    assert_equal [:verify_transloadit_notification], VerifyingController.callbacks
  end

  test "exposes the verified status with indifferent access" do
    controller = VerifyingController.new("transloadit" => PAYLOAD, "signature" => "valid")
    controller.client = FakeClient.new

    controller.run_callbacks

    assert_nil controller.response_status
    assert_equal "assembly-id", controller.transloadit_notification[:assembly_id]
  end

  test "answers notifications that fail authentication with 401" do
    controller = VerifyingController.new("transloadit" => PAYLOAD, "signature" => "forged")
    controller.client = FakeClient.new

    controller.run_callbacks

    assert_equal :unauthorized, controller.response_status
    assert_nil controller.transloadit_notification
  end

  test "verifies the raw form field after ParamsDecoder decoded params" do
    controller = DecodingController.new("transloadit" => PAYLOAD, "signature" => "valid")
    controller.client = FakeClient.new

    controller.run_callbacks

    assert_equal PAYLOAD, controller.client.received["transloadit"]
    assert_equal "assembly-id", controller.params[:transloadit][:assembly_id]
    assert_equal "assembly-id", controller.transloadit_notification[:assembly_id]
  end

  test "propagates configuration errors instead of answering 401" do
    controller = VerifyingController.new("transloadit" => PAYLOAD, "signature" => "valid")
    controller.client = Object.new
    controller.client.define_singleton_method(:verify_notification!) { |_fields| raise ArgumentError, "no secret" }

    assert_raises(ArgumentError) { controller.run_callbacks }
    assert_nil controller.response_status
  end

  test "explains which transloadit gem is required when it cannot verify" do
    controller = VerifyingController.new("transloadit" => PAYLOAD, "signature" => "valid")
    controller.client = Object.new

    error = assert_raises(NotImplementedError) { controller.run_callbacks }
    assert_match(/transloadit gem 4\.1\.0 or newer/, error.message)
  end

  # Keeps the job meant to cover real verification from passing on an older transloadit gem.
  if ENV["REQUIRE_NOTIFICATION_VERIFICATION"] == "1"
    test "resolves a transloadit gem that verifies notifications" do
      assert Transloadit.method_defined?(:verify_notification!)
    end
  end

  # Older transloadit gems, which the legacy Ruby jobs resolve, cannot verify notifications.
  if Transloadit.method_defined?(:verify_notification!)
    test "authenticates real signatures with the configured Auth Secret" do
      signature = OpenSSL::HMAC.hexdigest("SHA1", SECRET, PAYLOAD)
      client = Transloadit.new(key: "workspace-key", secret: SECRET)

      valid = VerifyingController.new("transloadit" => PAYLOAD, "signature" => "sha1:#{signature}")
      valid.client = client
      valid.run_callbacks
      assert_nil valid.response_status
      assert_equal "ASSEMBLY_COMPLETED", valid.transloadit_notification[:ok]

      tampered = VerifyingController.new("transloadit" => PAYLOAD.sub("COMPLETED", "CANCELED"), "signature" => signature)
      tampered.client = client
      tampered.run_callbacks
      assert_equal :unauthorized, tampered.response_status

      missing = VerifyingController.new("transloadit" => PAYLOAD)
      missing.client = client
      missing.run_callbacks
      assert_equal :unauthorized, missing.response_status
    end
  end

  test "uses the Auth Secret from the Rails configuration by default" do
    controller = Class.new(FakeController) { include Transloadit::Rails::NotificationVerifier }.new({})
    configured = Object.new
    original = Transloadit::Rails::Engine.method(:transloadit)
    silence_warnings do
      Transloadit::Rails::Engine.define_singleton_method(:transloadit) { |_options = {}| configured }
    end

    assert_same configured, controller.transloadit_notification_client
  ensure
    silence_warnings { Transloadit::Rails::Engine.define_singleton_method(:transloadit, original) }
  end
end
