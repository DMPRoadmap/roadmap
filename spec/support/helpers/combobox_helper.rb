module ComboboxHelper

  def choose_suggestion(suggestion_text)
    matching_element = all(:css, '.js-suggestion').detect do |element|
      element.text.strip == suggestion_text.strip
    end
    unless matching_element.present?
      raise ArgumentError, "No such suggestion with text '#{suggestion_text}'"
    end
    matching_element.click
    # Wait for the JS to run
    sleep(0.2)
  end

end