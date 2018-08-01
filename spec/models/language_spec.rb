require 'rails_helper'

RSpec.describe Language, type: :model do

  context "validations" do

    subject { build(:language) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:name).is_at_most(20) }

    it { is_expected.to validate_presence_of(:abbreviation) }

    it { is_expected.to validate_uniqueness_of(:abbreviation)
                          .with_message("must be unique") }

    it { is_expected.to allow_values('en', 'en_GB').for(:abbreviation) }

    it { is_expected.not_to allow_value('NOOP', 'en_', 'EN')
                              .for(:abbreviation) }

    it { is_expected.to validate_length_of(:abbreviation).is_at_most(5) }


  end

end
