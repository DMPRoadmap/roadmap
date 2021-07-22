# frozen_string_literal: true

require "rails_helper"

RSpec.describe MimeType, type: :model do

  context "associations" do
    it { is_expected.to have_many :research_outputs }
  end

  context "validations" do
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:value) }
  end

  it "factory builds a valid model" do
    expect(build(:mime_type).valid?).to eql(true)
  end

  context "scopes" do
    describe ":categories" do
      before(:each) do
        @categories = [Faker::Lorem.unique.word, Faker::Lorem.unique.word]
        @categories.each { |category| 2.times { create(:mime_type, category: category) } }
        @results = described_class.categories
      end

      it "returns a unique list of categories" do
        expect(@results.first).not_to eql(@results.last)
      end
      it "returns a sorted list of categories" do
        expect(@results).to eql(@categories.sort { |a, b| a <=> b })
      end
    end
  end

end
