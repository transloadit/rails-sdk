class Transloadit
  module RSpec
    # Provides helper methods to help stub a request to Transloadit in a non-JS request spec.
    module RequestSpecHelper
      # Stubs the relevant calls to the controller so as that a request spec can
      # test Transloadit parameters without needing to actually make a call to the
      # server.
      #
      # +controller+ should be the class of the controller you are about to invoke.
      # +params_json+ should be the JSON content as returned by Transloadit.
      #
      # It's usually easiest to make the request with your development environment,
      # capture the JSON response from the logs and use that in your tests.
      def stub_transloadit!(controller, params_json)
        hash =  ActiveSupport::HashWithIndifferentAccess.new(
          ActiveSupport::JSON.decode params_json
        )

        allow_any_instance_of(controller).to receive(:transloadit?).and_return(true)
        allow_any_instance_of(controller).to receive(:transloadit_params).and_return(hash)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Transloadit::RSpec::RequestSpecHelper, :type => :request
end
