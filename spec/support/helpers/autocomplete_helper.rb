module AutoCompleteHelper

  def select_an_org(autocomplete_id, org)
    # Set the Org Name
    find(autocomplete_id).set org.name
    sleep(0.2)

    # The controllers are expecting the org_id though, so lets
    # populate it
    hidden_id = autocomplete_id.gsub("_name", "_id").gsub("#", "")
    hash = { id: org.id, name: org.name }.to_json

    if hidden_id.present?
      page.execute_script(
        "document.getElementById('#{hidden_id}').value = '#{hash.to_s}'"
      );
    end
  end

  def choose_suggestion(suggestion_text)
    matcher = ".ui-autocomplete .ui-menu-item"
    matching_element = all(:css, matcher).detect do |element|
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
