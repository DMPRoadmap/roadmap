# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Region, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:abbreviation) }

    it {
      is_expected.to validate_uniqueness_of(:abbreviation).case_insensitive
                                                          .with_message('must be unique')
    }

    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to validate_presence_of(:name) }

    it {
      is_expected.to validate_uniqueness_of(:name).case_insensitive
                                                  .with_message('must be unique')
    }
  end

  context 'associations' do
    it { is_expected.to belong_to(:super_region).optional }

    it { is_expected.to have_many :sub_regions }
  end
end
