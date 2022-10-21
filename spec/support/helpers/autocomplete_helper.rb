# frozen_string_literal: true

module Helpers
  module AutocompleteHelper
    # rubocop:disable Metrics/AbcSize
    def select_an_org(selector, org_name, label)
      within(selector) do
        # Clear the default Org name if any and replace with the specified name
        fill_in label, with: ''
        fill_in label, with: org_name
        sleep(1)
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
    # rubocop:enable Metrics/AbcSize

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

      elements = all('.ui-menu-item-wrapper', visible: :all)
      return false unless elements.present? && elements.any?

      elements.detect { |el| el.text(:all).strip == name }.present?
    end

    # Commenting out DMPRoadmap code that will not work with out UI customizations
    # def choose_suggestion(typeahead_id, org)
    #   # fill_in(:org_org_name, with: org.name)
    #   fill_in(typeahead_id.to_sym, with: org.name)
    #
    #   id = typeahead_id.gsub('_name', '_id')
    #   # Some unfortunate hacks to deal with naming inconsistencies on the create plan page
    #   # and the Super Admin merge orgs tab
    #   id = id.gsub('org_org_', 'org_').gsub('funder_org_', 'funder_')
    #   # Excape any single quotes so it doesn't blow up our JS
    #   hash = { id: org.id, name: org.name.gsub("'", '') }
    #   # Capybara/Selenium can't interact with a hidden field because the user can't,
    #   # so use some JS to set the value
    #   page.execute_script "document.getElementById('#{id}').value = '#{hash.to_json}';"
    # end
  end
end