require 'rails_helper'

RSpec.describe OrgIdentifier, type: :model do

  context "validations" do

    it do
      # https://github.com/thoughtbot/shoulda-matchers/issues/682
      subject.identifier_scheme = create(:identifier_scheme)
      is_expected.to validate_uniqueness_of(:identifier_scheme_id)
                       .scoped_to(:org_id)
                       .with_message("must be unique")
    end

  end

  it { is_expected.to validate_presence_of(:identifier) }

  it { is_expected.to validate_presence_of(:org) }

  it { is_expected.to validate_presence_of(:identifier_scheme) }

end
