require 'rails_helper'

RSpec.describe QuestionFormat, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_uniqueness_of(:title)
                          .with_message("must be unique") }

    it { is_expected.to validate_presence_of(:description) }

    it { is_expected.to allow_values(true, false).for(:option_based) }

    it { is_expected.not_to allow_value(nil).for(:option_based) }

    it { is_expected.to allow_values(:textarea, :textfield, :radiobuttons,
                                     :checkbox, :dropdown, :multiselectbox,
                                     :date, :rda_metadata)
                          .for(:formattype) }

  end

  describe "#formattype" do

    it "raises an exception when value not recognised" do
      expect { subject.formattype = :foo }.to raise_error(ArgumentError)
    end

  end

end
