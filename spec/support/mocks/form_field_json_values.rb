# frozen_string_literal: true

module Mocks

  module FormFieldJsonValues

    # Mock JSON contents of the hidden org_id field used by the OrgSelectors
    def org_selector_id_field(org: create(:org))
      scheme = create(:identifier_scheme)
      identifier = create(:identifier, identifier_scheme: scheme, identifiable: org)
      { id: org.id, name: org.name, sort_name: org.name,
        "scheme.name.downcase": identifier.value }.to_json
    end

    # Mock JSON contents of the hidden org_crosswalk field used by the OrgSelectors
    def org_selector_crosswalk_field(org: create(:org))
      other = create(:org)
      [org_selector_id_field(org: other), org_selector_id_field(org: org)]
    end

    # Mock JSON contents of the hidden links field on Org pages
    def org_links_field
      { org: { link: Faker::Internet.url, text: Faker::Lorem.word } }.to_json
    end

  end

end
