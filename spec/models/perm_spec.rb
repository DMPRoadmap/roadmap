require 'rails_helper'

RSpec.describe Perm, type: :model do
  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_uniqueness_of(:name)
                          .with_message("must be unique") }
  end
end
