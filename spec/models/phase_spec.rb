# frozen_string_literal: true

require "rails_helper"

RSpec.describe Phase, type: :model do

  it_behaves_like "VersionableModel"

  context "validations" do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:number) }

    it { is_expected.to validate_presence_of(:template) }

    it "validates uniqueness of number" do
      subject.versionable_id = SecureRandom.uuid
      expect(subject).to validate_uniqueness_of(:number)
        .scoped_to(:template_id)
        .with_message("must be unique")
    end

    it { is_expected.to allow_values(true, false).for(:modifiable) }

    it { is_expected.not_to allow_value(nil).for(:modifiable) }

  end

  context "associations" do

    it { is_expected.to belong_to(:template) }

    it { is_expected.to have_one :prefix_section }

    it { is_expected.to have_many :sections }

    it { is_expected.to have_many :template_sections }

    it { is_expected.to have_many :suffix_sections }

  end

  describe ".titles" do

    let!(:phase) { create(:phase) }

    let!(:template) { phase.template }

    subject { Phase.titles(template.id) }

    before do
      @related_phases = create_list(:phase, 2, template: template)
      @strange_phases = create_list(:phase, 2)
    end

    it "returns related phases" do
      @related_phases.each do |phase|
        expect(subject).to include(phase)
      end
    end

    it "excludes phases of different Templates" do
      @strange_phases.each do |phase|
        expect(subject).not_to include(phase)
      end
    end

  end

  describe "#deep_copy" do

    let!(:phase) { create(:phase, modifiable: false) }

    let!(:options) { {} }

    subject { phase.deep_copy(options) }

    context "when no options are provided" do

      before do
        create_list(:section, 2, phase: phase)
      end

      it "checks number of sections" do
        expect(subject.sections.size).to eql(phase.sections.size)
      end

      it "doesn't persist the record" do
        expect(subject).to be_a_new_record
      end

      it "copies the description attribute" do
        expect(subject.description).to eql(phase.description)
      end

      it "copies the modifiable attribute" do
        expect(subject.modifiable).to eql(phase.modifiable)
      end

      it "copies the number attribute" do
        expect(subject.number).to eql(phase.number)
      end

      it "copies the title attribute" do
        expect(subject.title).to eql(phase.title)
      end

      it "sets template_id to nil" do
        expect(subject.template_id).to be_nil
      end

      it "duplicates the sections belonging to the Phase" do
        expect(subject.sections.count).to eql(subject.sections.count)
      end

    end

    context "when modifiable option is true" do

      let!(:options) { { modifiable: true } }

      it "sets the modifiable flag to true" do
        expect(subject.modifiable).to eql(true)
      end

    end

    context "when template_id option is present" do

      let!(:options) { { template_id: create(:template).id } }

      it "sets the template_id to new value" do
        expect(subject.template_id).to eql(options[:template_id])
      end

    end

    context "when save option is true" do

      let!(:options) { { save: true } }

      it "persists the record" do
        expect(subject).to be_persisted
      end

    end

  end

  describe "#num_answered_questions" do

    let!(:phase) { create(:phase) }

    subject { phase.num_answered_questions(plan) }

    context "when plan is nil" do

      let!(:plan) { nil }

      it "returns 0" do
        expect(subject).to be_zero
      end

    end

    context "when plan is present" do

      let!(:phase) { create(:phase, template: template) }

      let!(:section) { create(:section, phase: phase) }

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

      it "returns the sum of Plan's Phase's num_answered_questions" do
        expect(subject).to eql(2)
      end

    end
  end

  describe "#num_questions" do

    let!(:phase) { create(:phase) }

    before do
      create_list(:section, 2, phase: phase).each do |section|
        create_list(:question, 2, section: section)
      end
    end

    it "returns the number of related questions" do
      expect(phase.num_questions).to eql(4)
    end
  end

end
