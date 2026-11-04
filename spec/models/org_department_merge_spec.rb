# frozen_string_literal: true

require 'rails_helper'

# Org#merge! merges database records, rather than Hash entries.
# rubocop:disable Performance/RedundantMerge
RSpec.describe Org, 'department membership during merges', type: :model do
  let(:destination) { create(:org) }
  let(:source) { create(:org) }
  let(:department) { create(:department, org_id: source.id) }
  let!(:user) { create(:user, org: source, department: department) }

  it 'moves the department and user together during a bulk organization reassignment' do
    destination.merge!(to_be_merged: source)

    expect(user.reload.org).to eq(destination)
    expect(user.department).to eq(department)
    expect(department.reload.org).to eq(destination)
    expect(user).to be_valid
  end

  it 'clears assignments when a duplicate department is removed during a merge' do
    create(:department, org_id: destination.id, name: department.name)
    destination.merge!(to_be_merged: source)

    expect(user.reload.org).to eq(destination)
    expect(user.department).to be_nil
    expect(user).to be_valid
  end
end
# rubocop:enable Performance/RedundantMerge
