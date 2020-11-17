# frozen_string_literal: true

require "rails_helper"

RSpec.describe Answer, type: :model do

  context "validations" do
    subject { build(:answer) }

    it { is_expected.to validate_presence_of(:plan) }

    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:question) }

    it {
      is_expected.to validate_uniqueness_of(:question)
        .scoped_to(:plan_id)
        .with_message("must be unique")
    }
  end

  describe ".deep_copy" do

    let!(:answer) { build(:answer) }

    subject { Answer.deep_copy(answer) }

    it "creates a new record" do
      expect(subject).not_to eql(answer)
    end

    it "copies the lock_version attribute" do
      expect(subject.lock_version).to eql(answer.lock_version)
    end

    it "copies the text attribute" do
      expect(subject.text).to eql(answer.text)
    end

    it "copies the plan_id attribute" do
      expect(subject.plan_id).to eql(answer.plan_id)
    end

    it "copies the question_id attribute" do
      expect(subject.question_id).to eql(answer.question_id)
    end

    it "copies the user_id attribute" do
      expect(subject.user_id).to eql(answer.user_id)
    end
  end

  describe "#options_selected?" do

    let!(:answer) { create(:answer) }

    let!(:question_option) { create(:question_option) }

    subject { answer.options_selected?(question_option.id) }

    context "when answer has QuestionOption" do

      before do
        answer.question_options << question_option
      end

      it { is_expected.to eql(true) }

    end

    context "when answer doesn't have QuestionOption" do

      it { is_expected.to eql(false) }

    end

  end

  describe "#answered?" do

    subject { answer.answered? }

    describe "text based answer" do

      context "when text is nil" do

        let!(:answer) { build(:answer, text: nil) }

        it { is_expected.to eql(false) }

      end

      context "when text is ''" do

        let!(:answer) { build(:answer, text: "") }

        it { is_expected.to eql(false) }

      end

      context "when text is plain text" do

        let!(:answer) { build(:answer, text: "Foo bar") }

        it { is_expected.to eql(true) }

      end

      context "when text is empty html" do

        let!(:answer) { build(:answer, text: "<p><br/></p>") }

        it { is_expected.to eql(false) }

      end

      context "when text is html text" do

        let!(:answer) { build(:answer, text: "<p>Foo bar</p>") }

        it { is_expected.to eql(true) }

      end

    end

    describe "option based question" do

      let!(:answer) { create(:answer) }

      context "question present, question format is option and options empty" do

        before do
          answer.question.update(question_format:
                                   create(:question_format, option_based: true))
        end

        it { is_expected.to eql(false) }

      end

      context "question present, question format is option and options present" do

        before do
          answer.question.update(question_format:
                                   create(:question_format, option_based: true))

          answer.question_options << create_list(:question_option, 2)
        end

        it { is_expected.to eql(true) }

      end

      context "question present, question format not option and text empty" do

        before do
          answer.question.update(question_format:
                                   create(:question_format, option_based: false))

          answer.text = ""
        end

        it { is_expected.to eql(false) }

      end

      context "question present, question format not option and text present" do

        before do
          answer.question.update(question_format:
                                   create(:question_format, option_based: false))

          answer.text = "This is an answer"
        end

        it { is_expected.to eql(true) }

      end

      context "question absent" do

        before do
          answer.update(question: nil)
        end

        it { is_expected.to eql(false) }

      end

    end

  end

  describe "#non_archived_notes" do

    before do
      @answer         = create(:answer)
      @notes          = create_list(:note, 3, answer: @answer, archived: false)
      @archived_notes = create_list(:note, 3, answer: @answer, archived: true)
      @other_notes    = create_list(:note, 3)
    end

    subject { @answer.non_archived_notes }

    it "includes the non-archived notes" do
      @notes.each do |note|
        expect(subject).to include(note)
      end
    end

    it "excludes the archived notes" do
      @archived_notes.each do |note|
        expect(subject).not_to include(note)
      end
    end

    it "excludes notes belonging to other Answers" do
      @other_notes.each do |note|
        expect(subject).not_to include(note)
      end
    end

  end

  describe "#answer_hash" do

    let!(:answer) { build(:answer) }

    let(:default_json) { { "standards" => {}, "text" => "" } }

    subject { answer.answer_hash }

    context "when text is nil" do

      before do
        answer.text = nil
      end

      it { is_expected.to eql(default_json) }

    end

    context "when text is blank" do

      before do
        answer.text = ""
      end

      it { is_expected.to eql(default_json) }

    end

    context "when text is valid JSON" do

      before do
        answer.text = { name: "foo", bar: "baz" }.to_json
      end

      it { is_expected.to eql({ "name" => "foo", "bar" => "baz" }) }

    end

    context "when text is HTML" do

      before do
        answer.text = "<p>foo bar</p>"
      end

      it { is_expected.to eql(default_json) }

    end

  end

  describe "#update_answer_hash" do

    let!(:answer) { build(:answer) }

    subject { answer.answer_hash }

    context "when standards parameter is present" do

      before do
        answer.update_answer_hash({ foo: "bar" })
      end

      it { is_expected.to eql({ "standards" => { "foo" => "bar" }, "text" => "" }) }

    end

    context "when both params are absent" do

      before do
        answer.update_answer_hash
      end

      it { is_expected.to eql({ "standards" => {}, "text" => "" }) }

    end

    context "when both params are present" do

      before do
        answer.update_answer_hash({ foo: "bar" }, "baz")
      end

      it {
        is_expected.to eql({
                             "standards" => { "foo" => "bar" },
                             "text" => "baz"
                           })
      }

    end

  end

end
