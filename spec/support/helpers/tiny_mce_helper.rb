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
  def tinymce_fill_in(id, with: '')
    # wait until the TinyMCE editor instance is ready.
    # This is required for cases where the editor is loaded via XHR.
    x = 0
    until x == 50 || page.evaluate_script("tinyMCE.get('#{id}') !== null")
      x += 1
      sleep 0.2
    end
    begin
      page.execute_script <<~JS
        var editor = tinyMCE.get('#{id}');
        editor.setContent('#{with}');
        editor.fire('change');
      JS
    rescue Selenium::WebDriver::Error::UnknownError
      raise "No such tinyMCE element '##{id}'"
    end
  end

end