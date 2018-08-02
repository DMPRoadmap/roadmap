require 'rails_helper'

RSpec.describe UserIdentifier, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:identifier) }

    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:identifier_scheme) }

  end

  context "associations" do

    it { is_expected.to belong_to :user }

    it { is_expected.to belong_to :identifier_scheme }

  end

end
