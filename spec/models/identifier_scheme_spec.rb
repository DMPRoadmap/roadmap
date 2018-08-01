require 'rails_helper'

RSpec.describe IdentifierScheme, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:name).is_at_most(30) }

    it { is_expected.to allow_value(true).for(:name) }

    it { is_expected.to allow_value(false).for(:name) }

    it { is_expected.to_not allow_value(nil).for(:name) }

  end

end
