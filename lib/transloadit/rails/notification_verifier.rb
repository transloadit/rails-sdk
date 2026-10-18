require 'transloadit/rails'

#
# Authenticates Assembly notifications that Transloadit POSTs to your notify_url
# before your actions run, and answers forged or malformed ones with 401.
#
# Include it in the controller that receives notifications. Browser form submissions
# carry no notification signature, so keep those actions in a different controller.
#
module Transloadit::Rails::NotificationVerifier
  extend ActiveSupport::Concern

  included do
    if respond_to?(:before_action)
      before_action :verify_transloadit_notification
    else
      before_filter :verify_transloadit_notification
    end
  end

  # Returns the verified Assembly status as a HashWithIndifferentAccess.
  attr_reader :transloadit_notification

  def verify_transloadit_notification
    client = transloadit_notification_client
    unless client.respond_to?(:verify_notification!)
      raise NotImplementedError, 'Verifying notifications requires the transloadit gem 4.1.0 or newer'
    end

    # The raw form fields, so the signed JSON is checked byte for byte even after
    # ParamsDecoder replaced params[:transloadit] with its decoded value.
    status = begin
      client.verify_notification!(request.request_parameters)
    rescue Transloadit::Exception::InvalidSignature
      return head(:unauthorized)
    end

    @transloadit_notification = ActiveSupport::HashWithIndifferentAccess.new(status)
  end

  # Returns the client whose Auth Secret signs your notifications. Override it when
  # notifications for this controller are signed with a different Auth Key.
  def transloadit_notification_client
    Transloadit::Rails::Engine.transloadit
  end
end
