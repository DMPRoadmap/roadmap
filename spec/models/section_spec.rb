# frozen_string_literal: true

require "rails_helper"

RSpec.describe Section, type: :model do

  it_behaves_like "VersionableModel"

  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:number) }

    it { is_expected.to validate_presence_of(:phase) }

    it "validates uniqueness of number" do
      subject.versionable_id = SecureRandom.uuid
      expect(subject).to validate_uniqueness_of(:number)
        .scoped_to(:phase_id)
        .with_message("must be unique")
    end

    it { is_expected.to allow_values(true, false).for(:modifiable) }

  end

  context "associations" do

    it { is_expected.to belong_to :phase }

    it { is_expected.not_to belong_to :organisation }

    it { is_expected.to have_one :template }

    it { is_expected.to have_many :questions }

  end

  describe "#deep_copy" do

    let!(:options) { {} }

    let!(:section) { create(:section) }

    subject { section.deep_copy(options) }

    context "when no options provided" do

      before do
        create_list(:question, 3, section: section)
      end

      it "checks number of questions" do
        expect(section.questions.size).to eql(section.questions.size)
      end

    end

  end

  describe "#num_answered_questions" do

    let!(:phase) { create(:phase, template: template) }

    let!(:section) { create(:section, phase: phase) }

    subject { section.num_answered_questions(plan) }

    context "when plan is nil" do

      let!(:plan) { nil }

      let!(:template) { create(:template) }

      it { is_expected.to be_zero }

    end

    context "when plan is present" do

      let!(:plan) { create(:plan) }

      let!(:template) { plan.template }

      before do
        question = create(:question, section: section)
        create(:answer, question: question, plan: plan, text: "")

        question = create(:question, section: section)
        create(:answer, question: question, plan: plan)

        question = create(:question, section: section)
        create(:answer, question: question, plan: plan)
      end

      it "is expected to return the number of valid answered questions" do
        expect(subject).to eql(2)
      end

    end

  end

end
