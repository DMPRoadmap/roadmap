# frozen_string_literal: true

module AutoCompleteHelper

  def select_an_org(selector, org_name, namespace = nil)
    suggestions_selector = "#autocomplete-suggestions-"

    # Set the Org Name
    within(selector) do
      id = "#org_autocomplete_#{[namespace, "name"].compact.join("_")}"
      autocomplete = find(id)
      suggestions_selector += autocomplete[:list].split("-").last
      autocomplete.set(org_name)
    end

    sleep(0.1)

    # Now select the item from the suggestions
    within(selector) do
      item_selector = "#{suggestions_selector} .ui-menu-item-wrapper"

      matching_element = all(:css, item_selector).detect do |element|
        element.text.strip == org_name.strip
      end
      if matching_element.present?
        matching_element.click
      end
    end
  end

  # Supply a custom Org name
  def enter_custom_org(selector, org_name, namespace = nil)
    within(selector) do
      id = "#org_autocomplete_#{[namespace, "name"].compact.join("_")}"
      autocomplete = find(id)
      uuid = autocomplete[:list].split("-").last
      check "I cannot find my organisation in the list"
      find("#org_autocomplete_user_entered_name").set(org_name)
    end
  end

end
