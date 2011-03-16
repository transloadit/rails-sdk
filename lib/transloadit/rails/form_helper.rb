require 'transloadit/rails'

module Transloadit::Rails::FormHelper
  #
  # Inserts hidden fields specifying and signing the template for Transloadit
  # to process.
  #
  def transloadit(template, options = {})
    params    = Transloadit::Rails.template(template, options).to_json
    signature = Transloadit::Rails.sign(params)
    
    concat hidden_field_tag(:params,    params,    :id => nil)
    concat hidden_field_tag(:signature, signature, :id => nil)
  end
end
