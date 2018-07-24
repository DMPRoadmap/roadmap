require 'rails_helper'

RSpec.describe UserIdentifier, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:user) }
    it "validates uniqueness of identifier_scheme_id" do
      subject.identifier_scheme = create(:identifier_scheme)
      expect(subject).to validate_uniqueness_of(:identifier_scheme_id)
                           .case_insensitive
                           .scoped_to(:user_id)
                           .with_message("must be unique")
    end
    it { is_expected.to validate_presence_of(:identifier_scheme) }
  end
end
