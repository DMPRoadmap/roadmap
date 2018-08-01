require 'rails_helper'

RSpec.describe Region, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:abbreviation) }

    it { is_expected.to validate_uniqueness_of(:abbreviation)
                          .with_message("must be unique") }

    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to validate_presence_of(:name) }
  end
end
