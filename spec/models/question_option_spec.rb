# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuestionOption, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:question) }

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:number) }

    it { is_expected.to allow_values(true, false).for(:is_default) }

    it { is_expected.not_to allow_value(nil).for(:is_default) }

  end

  context "associations" do

    it { is_expected.to belong_to(:question) }

    it {
      is_expected.to have_and_belong_to_many(:answers)
        .join_table("answers_question_options")
    }
  end

  describe ".by_number" do

    subject { QuestionOption.by_number }

    before do
      @a = create(:question_option, number: 1)
      @b = create(:question_option, number: 3)
      @c = create(:question_option, number: 2)
    end

    it "orders records by the number attribute" do
      expect(subject.first).to eql(@a)
      expect(subject.last).to eql(@b)
    end

  end

  describe "#deep_copy" do

    let!(:options) { {} }

    let!(:question_option) { create(:question_option, is_default: true) }

    subject { question_option.deep_copy(options) }

    context "when no options provided" do

      it "builds a new record" do
        expect(subject).to be_new_record
      end

      it "copies is_default from original" do
        expect(subject.is_default).to eql(question_option.is_default)
      end

      it "copies number from original" do
        expect(subject.number).to eql(question_option.number)
      end

      it "copies text from original" do
        expect(subject.text).to eql(question_option.text)
      end

      it "sets question_id to nil" do
        expect(subject.question_id).to be_nil
      end

    end

    context "when question_id option is present" do

      let!(:question) { create(:question) }

      let!(:options) { { question_id: question.id } }

      it "sets question_id to given option" do
        expect(subject.question_id).to eql(question.id)
      end

    end
  end

end
