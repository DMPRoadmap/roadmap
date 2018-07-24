require 'rails_helper'

RSpec.describe TokenPermissionType, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:token_type) }
  end
end
