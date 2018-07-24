require 'rails_helper'

describe Plan do

  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:template) }

    it { is_expected.to allow_values(true, false).for(:feedback_requested) }

    it { is_expected.not_to allow_value(nil).for(:feedback_requested) }

    it { is_expected.to allow_values(true, false).for(:complete) }

    it { is_expected.not_to allow_value(nil).for(:complete) }
  end

end
