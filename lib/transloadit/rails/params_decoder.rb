require 'transloadit/rails'

module Transloadit::Rails::ParamsDecoder
  extend ActiveSupport::Concern

  included do
    before_filter :decode_transloadit_json
  end

  def decode_transloadit_json
    params[:transloadit] = transloadit_params
  end

  # Returns true if the current request has transloadit data.
  def transloadit?
    params[:transloadit].present?
  end

  # Returns the decoded transloadit parameters, or nil if the current request does not contain them.
  def transloadit_params
    return unless transloadit?

    # wrap transloadit params in a HashWithIndifferentAccess
    ActiveSupport::HashWithIndifferentAccess.new(
      ActiveSupport::JSON.decode params[:transloadit]
    )
  end
end
