module Transloadit::Rails::ParamsDecoder
  extend ActiveSupport::Concern

  included do
    before_filter :decode_transloadit_json
  end

  def decode_transloadit_json
    return unless params[:transloadit].present?

    # wrap transloadit params in a HashWithIndifferentAccess
    params[:transloadit] = ActiveSupport::HashWithIndifferentAccess.new(
      ActiveSupport::JSON.decode params[:transloadit]
    )
  end
end
