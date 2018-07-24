require 'rails_helper'

RSpec.describe Guidance, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:guidance_group) }

    it { is_expected.to allow_value(true).for(:published) }

    it { is_expected.to allow_value(false).for(:published) }

  end

end
