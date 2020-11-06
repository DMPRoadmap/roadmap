# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Template::UpgradeCustomizationService", type: :service do

  describe ".call" do

    let!(:funder_template) do
      ft = create(:template, :published, :default, org: create(:org, :funder))
      phase = create(:phase, template: ft)
      create_list(:section, 4, phase: phase).each do |section|
        create_list(:question, 2, section: section).each do |question|
          create_list(:annotation, 2, question: question)
        end
      end
      ft
    end

    let!(:template) { funder_template.customize!(create(:org, :funder)) }

    before do
      funder_template.publish!
      template.publish!
    end

    subject { Template::UpgradeCustomizationService.call(template) }

    context "when template is a customization of a published funder template" do

      it "returns a new Template" do
        expect(subject).to be_an_instance_of(Template)
      end

      it "returns a persisted Template" do
        expect(subject).to be_persisted
      end

      it "increments the version number" do
        template.update!(version: 2)
        expect(subject.version).to eql(3)
      end

      it "returns a draft Template" do
        expect(subject.published).to eql(false)
      end

      it "sets the customization_of to the family_id" do
        expect(subject.customization_of).to eql(template.customization_of)
        expect(subject.customization_of).to eql(funder_template.family_id)
      end

      it "sets the org to the template org" do
        expect(subject.org).to eql(template.org)
      end

      it "creates new phases for this Template" do
        expect { subject }.to change { Phase.count }.by(1)
      end

      it "creates new sections for this Template" do
        expect { subject }.to change { Section.count }.by(4)
      end

      it "creates new questions for this Template" do
        expect { subject }.to change { Question.count }.by(8)
      end

      it "creates new annotations for this Template" do
        expect { subject }.to change { Annotation.count }.by(16)
      end

    end

    context "when a new phase is present in funder template" do

      let!(:org) { create(:org) }

      let!(:template) { funder_template.customize!(org) }

      before do
        funder_template.phases << create(:phase)
      end

      it "copies the new sections" do
        expect(subject.phases).to have_exactly(2).items
      end

    end

    context "when a new section is present in funder template" do

      let!(:org) { create(:org) }

      let!(:template) { funder_template.customize!(org) }

      before do
        # Reverse the sections
        phase = funder_template.phases.first
        phase.sections << build(:section, title: "New funder section", number: 5, modifiable: true)
      end

      it "preserves the versionable_id" do
        subject.sections.each do |section|
          matching_section = funder_template.sections.detect do |s|
            # Note, there's no uniqueness criterion on the description
            s.description == section.description
          end
          expect(section.versionable_id).to eql(matching_section.versionable_id)
        end
      end

      # Doesn't need to. Number should be flexible if sections are modifiable
      it "preserves the number" do
        subject.sections.each do |section|
          matching_section = funder_template.sections.detect do |s|
            # Changing matching criteria as we validated versionable_id is preserved
            # above
            s.versionable_id == section.versionable_id
          end
          expect(section.number).to eql(matching_section.number)
        end
      end

    end

    context "when a new question is present in funder template" do

      let!(:org) { create(:org) }

      let!(:template) { funder_template.customize!(org) }

      before do
        funder_template.sections.first.questions << create(:question)
      end

      it "copies the new question" do
        expect(subject.questions).to have_exactly(9).items
      end

    end

    context "when a new annotation is present in funder template" do

      let!(:org) { create(:org) }

      let!(:template) { funder_template.customize!(org) }

      before do
        funder_template.questions.first.annotations << create(:annotation)
      end

      it "copies the new annotation" do
        expect(subject.annotations).to have_exactly(17).items
      end

    end

    context "when a new section is present in customized template" do

      let!(:org) { create(:org) }

      let!(:template) { funder_template.customize!(org) }

      before do
        template.phases.first.sections << create(:section, modifiable: true)
      end

      it "adds the new section to the new customization" do
        expect(subject.sections.count).to eql(funder_template.sections.count + 1)
      end

    end

    context "when a new section is present in both templates" do

      let!(:org) { create(:org) }

      let!(:template) { funder_template.customize!(org) }

      before do
        # Gave them different numbers >:]
        s = create(:section, phase: template.phases.first,
                             modifiable: true,
                             number: 6,
                             title: "Customized's test section")
        s.questions << create(:question)
        s = create(:section, phase: funder_template.phases.first,
                             modifiable: true,
                             number: 5,
                             title: "Funder's new section")
        s.questions << create(:question)
      end

      it "updates the customized template's new section with the next free number" do
        # Original 4 sections, plus new funder section, plus new customized section
        expect(subject.sections).to have_exactly(6).items
        expected = funder_template.sections.maximum(:number) + 1
        expect(subject.sections.maximum(:number)).to eql(expected)
      end

    end

    context "when a new annotation is present in customized template" do

      let!(:org) { create(:org) }

      let!(:template) { funder_template.customize!(org) }

      before do
        template.questions.first.annotations << create(:annotation, org: org)
        @annotation = Annotation.last
      end

      it "copies the new annotation" do
        expect(subject.annotations).to have_exactly(17).items
        annotation_vals = [@annotation.text, @annotation.versionable_id]
        expected_vals = subject.annotations.pluck(:text, :versionable_id)
        expect(expected_vals).to include(annotation_vals)
      end

    end

    context "when template is not a customization of a published funder template" do

      let!(:template) { create(:template) }

      it "raises an exception" do
        expect do
          subject
        end.to raise_error(Template::UpgradeCustomizationService::NotACustomizationError)
      end

    end

    context "when no published funder template exists" do

      let!(:funder_template) { create(:template, :archived, org: create(:org, :funder)) }

      it "raises an exception" do
        expect do
          subject
        end.to raise_error(Template::UpgradeCustomizationService::NoFunderTemplateError)
      end

    end

  end

end
