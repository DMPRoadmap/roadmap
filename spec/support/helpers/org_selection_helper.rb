# frozen_string_literal: true

module Helpers
  module OrgSelectionHelper
    def params_for_known_org_selection(org: create(:org))
      {
        org_autocomplete: {
          name: org.name, crosswalk: '', not_in_list: '0', user_entered_name: ''
        }
      }.with_indifferent_access
    end

    def params_for_unknown_org_selection(registry_org: create(:registry_org, org: nil))
      {
        org_autocomplete: {
          name: registry_org.name, crosswalk: '', not_in_list: '0', user_entered_name: ''
        }
      }.with_indifferent_access
    end

    def params_for_custom_org_entry(org_name: Faker::Company.unique.name)
      {
        org_autocomplete: {
          name: '', crosswalk: '', not_in_list: '1', user_entered_name: org_name.to_s
        }
      }.with_indifferent_access
    end
  end
end
