require 'transloadit/rails/engine'

module Transloadit::Rails::ViewHelper
  #
  # Inserts hidden fields specifying and signing the template for Transloadit
  # to process.
  #
  # template - The String or Symbol template name.
  # options  - The Hash options used to refine the Assembly (default: {}):
  #            :steps    - The Hash with Assembly Steps (optional).
  #            :max_size - The Integer maximum size an upload can have in bytes (optional).
  def transloadit(template, options = {})
    params = Transloadit::Rails::Engine.template(template, options).to_json
    fields = hidden_field_tag(:transloadit, params, :id => nil)

    if Transloadit::Rails::Engine.configuration['auth']['secret'].present?
      signature = Transloadit::Rails::Engine.sign(params)
      fields << hidden_field_tag(:signature, signature, :id => nil)
    end

    fields
  end

  #
  # Enables the jQuery integration for Transloadit, and ensures the form is
  # marked with an encoding type of `multipart/form-data`.
  #
  def transloadit_jquerify(id, options = {})
    version = Transloadit::Rails::Engine.configuration['jquery_sdk_version'] || 'v2-latest'

    javascript_tag %{
      jQuery(function($) {
        var script = '//assets.transloadit.com/js/jquery.transloadit2-#{version}.js';

        $.getScript(script, function() {
          $('##{id}')
            .attr('enctype', 'multipart/form-data')
            .transloadit(#{options_to_json(options)});
        });
      });
    }
  end

  private

    def options_to_json(options)
      callbacks = [
        :onstart, :onfileselect, :onprogress, :onupload, :onresult, :oncancel, :onerror, :onsuccess
      ]

      js_options = options.map do |key, val|
        "#{key.to_json}: #{callbacks.include?(key.downcase) ? val : val.to_json}"
      end.join(",\n")

      "{#{js_options}}"
    end
end
