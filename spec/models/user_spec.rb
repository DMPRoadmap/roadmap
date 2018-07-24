require 'rails_helper'

RSpec.describe User, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:email) }

    it "should validate that email addres is unqique" do
      subject.email = "text-email@example.com"
      is_expected.to validate_uniqueness_of(:email)
                       .case_insensitive
                       .with_message("has already been taken")
    end

    it { is_expected.to allow_values("one@example.com", "foo-bar@ed.ac.uk")
                          .for(:email) }

    it { is_expected.not_to allow_values("example.com", "foo bar@ed.ac.uk")
                              .for(:email) }

    it { is_expected.to allow_values(true, false).for(:active) }

    it { is_expected.not_to allow_value(nil).for(:active) }
  end
end
