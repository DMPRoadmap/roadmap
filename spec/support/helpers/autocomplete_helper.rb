# frozen_string_literal: true

module AutocompleteHelper
  def select_an_org(selector, org_name, label)
    within(selector) do
      # Clear the default Org name if any and replace with the specified name
      fill_in label, with: ''
      fill_in label, with: org_name
      # Check that it appear in the list first
      expect(suggestion_exists?(org_name)).to eql(true)
      # Now select the item from the suggestions
      elements = all('.ui-menu-item-wrapper', visible: false)
      return false unless elements.present? && elements.any?

      selection = elements.detect { |el| el.text.strip == org_name }
      return false unless selection.present?

      selection.click
    end
  end

  # Supply a custom Org name
  def enter_custom_org(selector, org_name, namespace = nil)
    prefix = ['org', 'autocomplete', namespace].compact.join('_')
    within(selector) do
      # The dmptool-ui displays a checkbox and the underlying input is always hidden
      find("label[for=\"#{prefix}_not_in_list\"]").click
      field = find("##{prefix}_user_entered_name")
      expect(field.present?).to eql(true)
      field.set(org_name)
    end
  end

  # Checks the suggestions to see if the name exists.
  def suggestion_exists?(name)
    return false unless name.present?

    elements = all('.ui-menu-item-wrapper', visible: false)
    return false unless elements.present? && elements.any?

elements.detect { |el| pp "'#{el.text.strip}' == '#{name}'" }

    elements.detect { |el| el.text.strip == name }.present?
  end
end
