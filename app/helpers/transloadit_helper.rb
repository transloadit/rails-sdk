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
            .transloadit($.extend(#{options.to_json}, typeof(transloadit_callbacks) !== 'undefined' ? transloadit_callbacks : {});
        });
      });
    }
  end
end
