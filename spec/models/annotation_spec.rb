require 'rails_helper'

RSpec.describe Annotation, type: :model do

  context "validations" do

    subject { build(:annotation) }

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:question) }

    it { is_expected.to validate_presence_of(:type) }

  end

end
