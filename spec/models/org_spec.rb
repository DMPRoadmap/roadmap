require 'rails_helper'

RSpec.describe Org, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it {
      subject.name = "DMP Company"
      is_expected.to validate_uniqueness_of(:name)
                          .with_message("must be unique")
    }

    it { is_expected.to validate_presence_of(:abbreviation) }

    it { is_expected.to allow_values(true, false).for(:is_other) }

    it { is_expected.not_to allow_value(nil).for(:is_other) }

    it { is_expected.to validate_presence_of(:language) }

    it "validates presence of contact_email if feedback_enabled" do
      subject.feedback_enabled = true
      is_expected.to validate_presence_of(:contact_email)
    end

    it "doesn't validate presence of contact_email if feedback_enabled nil" do
      subject.feedback_enabled = false
      is_expected.not_to validate_presence_of(:contact_email)
    end

    # validates :contact_email, presence: { message: PRESENCE_MESSAGE,
    #                                       if: :feedback_enabled }
    #
    # validates :org_type, presence: { message: PRESENCE_MESSAGE }
    #
    # validates :feedback_enabled, inclusion: { in: BOOLEAN_VALUES,
    #                                           message: INCLUSION_MESSAGE }
    #
    # validates :feedback_email_subject, presence: { message: PRESENCE_MESSAGE,
    #                                                if: :feedback_enabled }
    #
    # validates :feedback_email_msg, presence: { message: PRESENCE_MESSAGE,
    #                                            if: :feedback_enabled }
    #
  end

end
