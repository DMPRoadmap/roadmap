# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiLog, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:activity) }
    it { is_expected.to validate_presence_of(:api_client) }
    it { is_expected.to validate_presence_of(:change_type) }
    it { is_expected.to validate_presence_of(:logable) }

    it { is_expected.to define_enum_for(:change_type).with_values(ApiLog.change_types.keys) }
  end

  context 'Associations' do
    it { is_expected.to belong_to(:api_client) }
    it { is_expected.to belong_to(:logable) }
  end
end
