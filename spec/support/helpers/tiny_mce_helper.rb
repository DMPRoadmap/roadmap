# frozen_string_literal: true

# This module provides helper methods for testing TinyMCE within feature specs
module TinyMceHelper

  ##
  # Fill in TinyMCE field with given text.
  #
  # id  - String with the id attribute of the editor instance (without the #)
  # val - String with the value to input to the text field
  #
  # Returns String
  def tinymce_fill_in(id, val)
    # wait until the TinyMCE editor instance is ready.
    # This is required for cases where the editor is loaded via XHR.
    sleep 0.2 until page.evaluate_script("tinyMCE.get('#{id}') !== null")

    page.execute_script <<~JS
      tinyMCE.get('#{id}').setContent('#{val}')
    JS
  end

end