require 'rails_helper'

RSpec.describe Role, type: :model do

  context "validations" do
    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:plan) }

    it { is_expected.to allow_values(true, false).for(:active) }

    it { is_expected.not_to allow_value(nil).for(:active) }

    it { is_expected.to validate_numericality_of(:access)
                          .only_integer
                          .is_greater_than(0)
                          .with_message("can't be less than zero") }

  end

end
