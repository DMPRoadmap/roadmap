require 'rails_helper'

RSpec.describe Theme, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:description) }

  end

  context "associations" do

    it { is_expected.to have_and_belong_to_many(:questions)
                          .join_table("questions_themes") }

    it { is_expected.to have_and_belong_to_many(:guidances)
                          .join_table("themes_in_guidance") }

  end

  describe ".search" do

    let!(:term) { "foo" }

    subject { Theme.search(term) }

    context "when neither title or description matches term" do

      let!(:theme) { create(:theme) }

      it { is_expected.not_to include(theme) }

    end

    context "when title is a match for term" do

      let!(:theme) { create(:theme, title: "The title is foo bar") }

      it { is_expected.to include(theme) }

    end

    context "when description is a match for term" do

      let!(:theme) { create(:theme, description: "The title is foo bar") }

      it { is_expected.to include(theme) }

    end

  end

  describe "#to_s" do

    let!(:theme) { create(:theme) }

    subject { theme.to_s }

    it "returns the title" do
      expect(subject).to eql(theme.title)
    end
  end

end
