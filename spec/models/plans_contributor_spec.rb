# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansContributor, type: :model do

  context "associations" do
    it { is_expected.to belong_to(:contributor) }
    it { is_expected.to belong_to(:plan) }
  end

end
