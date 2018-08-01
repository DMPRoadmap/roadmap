require 'rails_helper'

RSpec.describe QuestionOption, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:question) }

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:number) }

    it { is_expected.to allow_values(true, false).for(:is_default) }

    it { is_expected.not_to allow_value(nil).for(:is_default) }

  end
end
