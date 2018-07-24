require 'rails_helper'

RSpec.describe Notification, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:notification_type) }

    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:level) }

    it { is_expected.to validate_presence_of(:body) }

    it { is_expected.to allow_values(true, false).for(:dismissable) }

    it { is_expected.not_to allow_value(nil).for(:dismissable) }

    it { is_expected.to validate_presence_of(:starts_at) }

    it { is_expected.to validate_presence_of(:expires_at) }

    it { is_expected.to allow_value(Date.today).for(:starts_at) }

    it { is_expected.not_to allow_value(1.day.ago).for(:starts_at) }

    it { is_expected.to allow_value(2.days.from_now).for(:expires_at) }

    it { is_expected.not_to allow_value(Date.today).for(:expires_at) }

  end

end
