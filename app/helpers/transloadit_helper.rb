module TransloaditHelper  
  #
  # Enables the jQuery integration for Transloadit, and ensures the form is
  # marked with an encoding type of `multipart/form-data`.
  #
  def transloadit_jquerify(id, options = {})
    javascript_tag %{
      $(document).ready(function() {
        var script = '#{javascript_path('jquery.transloadit2.js')}';
        
        $.getScript(script, function() {
          $('##{id}').attr('enctype', 'multipart/form-data');
          $('##{id}').transloadit(#{options.to_json});
        });
      });
    }
  end
end
