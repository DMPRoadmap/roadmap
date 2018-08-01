require 'rails_helper'

RSpec.describe Answer, type: :model do

  context "validations" do
    subject { build(:answer) }

    it { is_expected.to validate_presence_of(:plan) }

    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:question) }

    it { is_expected.to validate_uniqueness_of(:question)
                          .scoped_to(:plan_id)
                          .with_message("must be unique") }
  end

end
