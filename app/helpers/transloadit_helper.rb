module TransloaditHelper  
  #
  # Enables the jQuery integration for Transloadit, and ensures the form is
  # marked with an encoding type of `multipart/form-data`.
  #
  def transloadify(id = _guess_at_id, options = {})
    javascript_tag %{
      $(document).ready(function() {
        $.getScript('#{javascript_path('jquery.transloadit2.js')}');
        $('##{_guess_at_id}').attr('enctype', 'multipart/form-data');
        $('##{_guess_at_id}').transloadit(#{options.to_json});
      });
    }
  end
  
  protected
  
  #
  # Tries to use the FormBuilder approach to guessing the HTML id of the
  # form.
  #
  def _guess_at_id
    @_guessed_id ||= options.fetch(:html).fetch(:id) rescue begin
      object.respond_to?(:persisted?) && object.persisted? ?
        options[:as] ? "#{options[:as]}_edit" : dom_id(object, :edit) :
        options[:as] ? "#{options[:as]}_new"  : dom_id(object, :new)
    end
  end
end
