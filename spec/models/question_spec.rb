# frozen_string_literal: true

require "rails_helper"

RSpec.describe Question, type: :model do

  it_behaves_like "VersionableModel"

  context "validations" do

    it {
      is_expected.to validate_presence_of(:text)
        .with_message("for 'Question text' can't be blank.")
    }

    it { is_expected.to validate_presence_of(:number) }

    it "validates uniqueness of number" do
      subject.versionable_id = SecureRandom.uuid
      expect(subject).to validate_uniqueness_of(:number)
        .scoped_to(:section_id)
        .with_message("must be unique")
    end

    it { is_expected.to validate_presence_of(:section).on(:update) }

    it { is_expected.to validate_presence_of(:question_format) }

    it { is_expected.to allow_values(true, false).for(:option_comment_display) }

    it { is_expected.to allow_value(nil).for(:option_comment_display) }

    it { is_expected.to allow_values(true, false).for(:modifiable) }

    it { is_expected.to allow_value(nil).for(:modifiable) }

  end

  context "associations" do

    it { is_expected.to belong_to :section }

    it { is_expected.to belong_to :question_format }

    it { is_expected.to have_one :phase }

    it { is_expected.to have_one :template }

    it { is_expected.to have_many :answers }

    it { is_expected.to have_many :question_options }

    it { is_expected.to have_many :annotations }

    it {
      is_expected.to have_and_belong_to_many(:themes)
        .join_table("questions_themes")
    }

  end

  describe "#to_s" do

    before do
      subject.text = "foo bar"
    end

    it "returns the Question's text" do
      expect(subject.to_s).to eql("foo bar")
    end

  end

  describe "#option_based?" do

    subject { question_format.option_based? }

    context "when QuestionFormat is option_based and has at least one option" do

      let!(:question_format) { create(:question_format, option_based: true) }
      let!(:question) { create(:question, question_format: question_format, options: 1) }

      it { is_expected.to eql(true) }

    end

    context "when QuestionFormat is option_based and has no option" do

      let!(:question_format) { create(:question_format, option_based: true) }

      # rubocop:disable Layout/LineLength
      it {
        expect do
          create(:question, question_format: question_format, options: 0)
        end.to raise_error(ActiveRecord::RecordInvalid,
                           "Validation failed: You must have at least one option with accompanying text.")
      }
      # rubocop:enable Layout/LineLength

      it { is_expected.to eql(true) }

    end

    context "when QuestionFormat is not option_based" do

      let!(:question_format) { create(:question_format, option_based: false) }
      let!(:question) { create(:question, question_format: question_format) }

      it { is_expected.to eql(false) }

    end
  end

  describe "#deep_copy" do

    let!(:question) do
      create(:question,
             default_value: "foo bar",
             modifiable: true,
             number: 12,
             option_comment_display: false,
             text: "How many foos can bar?")
    end

    let!(:options) { {} }

    subject { question.deep_copy(options) }

    context "when no options are provided" do

      before do
        create_list(:question_option, 4, question: question)
      end

      it "checks number of question options" do
        expect(subject.question_options.size).to eql(question.question_options.size)
      end

      it "doesn't persist the record" do
        expect(subject).to be_new_record
      end

      it "copies default_value from original Question" do
        expect(subject.default_value).to eql("foo bar")
      end

      it "copies modifiable from original Question" do
        expect(subject.modifiable).to eql(true)
        question.modifiable = false
        expect(question.deep_copy.modifiable).to eql(false)
      end

      it "copies number from original Question" do
        expect(subject.number).to eql(12)
      end

      it "copies option_comment_display from original Question" do
        expect(subject.option_comment_display).to eql(false)
      end

      it "copies text from original Question" do
        expect(subject.text).to eql("How many foos can bar?")
      end

      it "copies question_format_id from original Question" do
        expect(subject.question_format_id).to eql(question.question_format_id)
      end

      it "sets section_id to nil" do
        expect(subject.section_id).to be_nil
      end

    end

    context "when modifiable option provided" do

      let!(:options) { { modifiable: true } }

      it "copies modifiable from option" do
        expect(subject.modifiable).to eql(true)
        question.modifiable = false
        expect(question.deep_copy.modifiable).to eql(false)
      end

      it "ignores the original record's value" do
        question.modifiable = false
        expect(question.deep_copy(options).modifiable).to eql(true)
      end

    end

    context "when section_id option provided" do

      let!(:section) { create(:section) }

      let!(:options) { { section_id: section.id } }

      it "sets the section_id attribute" do
        expect(subject.section_id).to eql(section.id)
      end

    end

    context "when save option provided" do

      let!(:options) { { save: true } }

      it "persists the record to the database" do
        expect(subject).to be_persisted
      end
    end
  end

  describe "#example_answers" do

    subject { question.example_answers([org.id]) }

    let!(:question) { create(:question) }

    let!(:org) { create(:org) }

    context "when belongs to Org and type 'Example answer'" do

      let!(:annotation) do
        create(:annotation, question: question, org: org,
                            type: Annotation.types[:example_answer])
      end

      it { is_expected.to include(annotation) }

    end

    context "when belongs to Org and type 'Guidance'" do

      let!(:annotation) do
        create(:annotation, question: question, org: org,
                            type: Annotation.types[:guidance])
      end

      it { is_expected.not_to include(annotation) }

    end

    context "when belongs to other Org and type 'Example answer'" do

      let!(:annotation) do
        create(:annotation, question: question,
                            type: Annotation.types[:guidance])
      end

      it { is_expected.not_to include(annotation) }

    end

  end

  describe "#guidance_annotation" do

    subject { question.guidance_annotation(org.id) }

    let!(:question) { create(:question) }

    let!(:org) { create(:org) }

    context "when Annotation type is 'guidance' and belongs to Org" do

      let!(:annotation) do
        create(:annotation,
               org: org,
               question: question,
               type: Annotation.types[:guidance])
      end

      it { is_expected.to eql(annotation) }

    end

    context "when Annotation type is 'Example Answer' and belongs to Org" do

      let!(:annotation) do
        create(:annotation,
               org: org,
               question: question,
               type: Annotation.types[:example_answer])
      end

      it { is_expected.to be_nil }

    end

    context "when Annotation type is 'guidance' and doesn't belong to Org" do

      let!(:annotation) do
        create(:annotation,
               question: question,
               type: Annotation.types[:guidance])
      end

      it { is_expected.to be_nil }

    end

    context "when Annotation type 'Example Answer' and doesn't belong to Org" do

      let!(:annotation) do
        create(:annotation,
               question: question,
               type: Annotation.types[:example_answer])
      end

      it { is_expected.to be_nil }

    end

  end

  describe "#annotations_per_org" do

    subject { question.annotations_per_org(org.id) }

    let!(:org) { create(:org) }

    let!(:question) { create(:question) }

    context "when example answer already present" do

      before do
        create(:annotation, type: Annotation.types[:example_answer],
                            org: org, question: question)
      end

      it "returns the existing annotation" do
        expect(subject.first).to be_persisted
      end

      it "returns example answer" do
        expect(subject.first).to be_example_answer
      end

    end

    context "when example answer not present" do

      it "returns the existing annotation" do
        expect(subject.first).to be_new_record
      end

      it "returns example answer" do
        expect(subject.first).to be_example_answer
      end

    end

    context "when guidance already present" do

      before do
        create(:annotation, type: Annotation.types[:guidance],
                            org: org, question: question)
      end

      it "returns the existing annotation" do
        expect(subject.last).to be_persisted
      end

      it "returns example answer" do
        expect(subject.last).to be_guidance
      end

    end

    context "when guidance not present" do

      it "returns the existing annotation" do
        expect(subject.last).to be_new_record
      end

      it "returns example answer" do
        expect(subject.last).to be_guidance
      end

    end

  end

end
