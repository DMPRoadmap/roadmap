# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FlagShihTzu stored values', type: :model do
  it 'selects organisation types from the same stored bits' do
    org = create(:org, org_type: 3)

    expect(org).to be_institution
    expect(org).to be_funder
    expect(Org.institution).to include(org)
    expect(Org.funder).to include(org)
    expect(Org.school).not_to include(org)
  end

  it 'selects plan access from the same stored bits' do
    role = create(:role, access: 5)

    expect(role).to be_creator
    expect(role).to be_editor
    expect(Role.creator).to include(role)
    expect(Role.editor).to include(role)
    expect(Role.reviewer).not_to include(role)
  end

  it 'selects contributor roles from the same stored bits' do
    contributor = create(:contributor, plan: create(:plan), roles: 3, roles_count: 0)

    expect(contributor).to be_data_curation
    expect(contributor).to be_investigation
    expect(Contributor.data_curation).to include(contributor)
    expect(Contributor.investigation).to include(contributor)
    expect(Contributor.other).not_to include(contributor)
  end
end
