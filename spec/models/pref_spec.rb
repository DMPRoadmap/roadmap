# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pref do
  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:settings) }
  end

  describe '.default_settings' do
    it 'returns Rails configuration for preferences' do
      expect(described_class.default_settings).to eql(Rails.configuration.x.application.preferences)
      expect(described_class.default_settings).not_to be_nil
    end
  end
end
