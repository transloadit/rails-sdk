module TransloaditHelper  
  #
  # Enables the jQuery integration for Transloadit, and ensures the form is
  # marked with an encoding type of `multipart/form-data`.
  #
  def transloadit_jquerify(id, options = {})
    javascript_tag %{
      jQuery(function($) {
        var script = '//assets.transloadit.com/js/jquery.transloadit2.js';

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
        :onstart, :onprogress, :onupload, :onresult, :oncancel, :onerror, :onsuccess
      ]

      js_options = options.map do |key, val|
        "#{key.to_json}: #{callbacks.include?(key.downcase) ? val : val.to_json}"
      end.join(",\n")

      "{#{js_options}}"
    end
end
