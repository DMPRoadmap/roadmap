# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Department, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to allow_value(nil).for(:code) }

    it 'validates uniqueness of name' do
      org = create(:org)
      subject = create(:department, org_id: org.id)
      expect(subject).to validate_uniqueness_of(:name)
        .scoped_to(:org_id)
        .case_insensitive
        .with_message('must be unique')
    end
  end

  context 'associations' do
    it { is_expected.to belong_to :org }

    it { is_expected.to have_many :users }
  end
end
