# frozen_string_literal: true

require "rails_helper"

describe ResearchDomain do

  context "associations" do
    it { is_expected.to have_many :sub_fields }
    it { is_expected.to belong_to(:parent).optional }
  end

end
