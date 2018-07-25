require 'rails_helper'

RSpec.describe GuidanceGroup, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_uniqueness_of(:name)
                          .with_message('must be unique') }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to allow_value(true).for(:optional_subset)  }

    it { is_expected.to allow_value(true).for(:published) }

    it { is_expected.to allow_value(false).for(:optional_subset)  }

    it { is_expected.to allow_value(false).for(:published) }

  end

end
