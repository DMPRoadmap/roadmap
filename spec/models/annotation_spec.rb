# frozen_string_literal: true

require "rails_helper"

RSpec.describe Annotation, type: :model do

  it_behaves_like "VersionableModel"

  context "validations" do

    subject { build(:annotation) }

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:question) }

    it { is_expected.to validate_presence_of(:type) }

  end

  describe "#to_s" do

    let!(:annotation) { build(:annotation) }

    subject { annotation.to_s }

    it { is_expected.to eql(annotation.text) }

  end

  describe "#deep_copy" do

    context "when question_id option is nil" do

      before do
        @annotation = create(:annotation)
        @new_annotation = @annotation.deep_copy
      end

      it "creates a different record" do
        expect(@new_annotation).not_to eql(@annotation)
      end

      it "copies the text attribute" do
        expect(@new_annotation.text).to eql(@annotation.text)
      end

      it "copies the type attribute" do
        expect(@new_annotation.type).to eql(@annotation.type)
      end

      it "copies the org_id attribute" do
        expect(@new_annotation.org_id).to eql(@annotation.org_id)
      end

      it "sets question_id to nil" do
        expect(@new_annotation.question_id).to be_nil
      end

    end

    context "when question_id option is set" do

      before do
        @annotation = create(:annotation)
        @new_annotation = @annotation.deep_copy(question_id: 1)
      end

      it "sets question_id to nil" do
        expect(@new_annotation.question_id).to eql(1)
      end

    end

  end

end
