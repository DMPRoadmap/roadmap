require 'rails_helper'

RSpec.describe Note, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:answer) }

    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to allow_values(true, false).for(:archived) }

    it { is_expected.not_to allow_value(nil).for(:archived) }

  end

end
