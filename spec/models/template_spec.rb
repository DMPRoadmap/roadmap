require 'rails_helper'

RSpec.describe Template, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to allow_values(true, false).for(:published) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:published) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:locale) }

    it { is_expected.to allow_values(true, false).for(:is_default) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:is_default) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:version) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:visibility) }

    # This is currently being set in the defaults before validation
    # it { is_expected.to validate_presence_of(:family_id) }

    it { is_expected.to allow_values(true, false).for(:archived) }

    # This is currently being set in the defaults before validation
    # it { is_expected.not_to allow_value(nil).for(:archived) }
  end
end
