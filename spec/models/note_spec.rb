# frozen_string_literal: true

require "rails_helper"

RSpec.describe Note, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:answer) }

    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to allow_values(true, false).for(:archived) }

    it { is_expected.not_to allow_value(nil).for(:archived) }

  end

  context "associations" do

    it { is_expected.to belong_to :answer }

    it { is_expected.to belong_to :user }

  end

end
