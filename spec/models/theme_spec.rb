require 'rails_helper'

RSpec.describe Theme, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:description) }
  end
end
