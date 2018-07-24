require 'rails_helper'

RSpec.describe Phase, type: :model do
  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:number) }

    it { is_expected.to validate_presence_of(:template) }

    it { is_expected.to validate_uniqueness_of(:number)
                          .scoped_to(:template_id)
                          .with_message("must be unique") }

    it { is_expected.to allow_values(true, false).for(:modifiable) }

    it { is_expected.not_to allow_value(nil).for(:modifiable) }

  end
end
