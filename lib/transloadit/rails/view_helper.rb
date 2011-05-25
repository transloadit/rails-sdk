require 'transloadit/rails/engine'

module Transloadit::Rails::ViewHelper
  #
  # Inserts hidden fields specifying and signing the template for Transloadit
  # to process.
  #
  def transloadit(template, options = {})
    params    = Transloadit::Rails::Engine.template(template, options).to_json
    signature = Transloadit::Rails::Engine.sign(params)

    hidden_field_tag(:params,    params,    :id => nil) +
    hidden_field_tag(:signature, signature, :id => nil)
  end
end
