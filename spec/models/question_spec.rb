require 'rails_helper'

RSpec.describe Question, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:number) }

    it { is_expected.to validate_uniqueness_of(:number)
                          .scoped_to(:section_id)
                          .with_message("must be unique") }

    it { is_expected.to validate_presence_of(:section) }


    it { is_expected.to validate_presence_of(:question_format) }

    it { is_expected.to allow_values(true, false).for(:option_comment_display) }

    it { is_expected.to allow_value(nil).for(:option_comment_display) }

    it { is_expected.to allow_values(true, false).for(:modifiable) }

    it { is_expected.to allow_value(nil).for(:modifiable) }

  end

end
