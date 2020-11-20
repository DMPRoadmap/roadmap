# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResearchOutput, type: :model do

  context "associations" do
    it { is_expected.to belong_to(:plan).optional }
    it { is_expected.to belong_to(:mime_type).optional }
  end

  # rubocop:disable Layout/LineLength
  context "validations" do
    before(:each) do
      @subject = create(:research_output, plan: create(:plan))
    end
    it { is_expected.to define_enum_for(:access).with_values(ResearchOutput.accesses.keys) }
    it { is_expected.to define_enum_for(:output_type).with_values(ResearchOutput.output_types.keys) }

    it { is_expected.to validate_presence_of(:output_type) }
    it { is_expected.to validate_presence_of(:access) }
    it { is_expected.to validate_presence_of(:title) }

    it { expect(@subject).to validate_uniqueness_of(:title).scoped_to(:plan_id) }
    it { expect(@subject).to validate_uniqueness_of(:abbreviation).scoped_to(:plan_id) }

    it "requires :output_type_description if :output_type is 'other'" do
      @subject.other!
      expect(@subject).to validate_presence_of(:output_type_description)
    end
    it "does not require :output_type_description if :output_type is 'dataset'" do
      @subject.dataset!
      expect(@subject).not_to validate_presence_of(:output_type_description)
    end

    describe ":coverage_start and :coverage_end" do
      it "allows coverage_start to be nil" do
        @subject.coverage_start = nil
        expect(@subject.valid?).to eql(true)
      end
      it "allows end_date to be nil" do
        @subject.coverage_end = nil
        expect(@subject.valid?).to eql(true)
      end
      it "does not allow end_date to come before start_date" do
        @subject.coverage_end = Time.now
        @subject.coverage_start = Time.now + 2.days
        expect(@subject.valid?).to eql(false)
      end
    end
  end
  # rubocop:enable Layout/LineLength

  it "factory builds a valid model" do
    expect(build(:research_output).valid?).to eql(true)
    expect(build(:research_output, :complete).valid?).to eql(true)
  end

  describe "cascading deletes" do
    it "does not delete associated plan" do
      model = create(:research_output, :complete, plan: create(:plan))
      plan = model.plan
      model.destroy
      expect(Plan.last).to eql(plan)
    end
    it "does not delete associated mime_type" do
      model = create(:research_output, :complete, plan: create(:plan))
      mime_type = model.mime_type
      model.destroy
      expect(MimeType.last).to eql(mime_type)
    end
  end

  context "instance methods" do
    describe ":available_mime_types" do
      before(:each) do
        @audiovisuals = %w[audio video].map do |cat|
          create(:mime_type, category: cat)
        end
        @audiovisuals = @audiovisuals.sort { |a, b| a.description <=> b.description }
        @images = [create(:mime_type, category: "image")]
        @texts = [create(:mime_type, category: "text")]
        @models = [create(:mime_type, category: "model")]
        @subject = build(:research_output)
      end
      it "returns an empty array if no :output_type is present" do
        @subject.output_type = nil
        expect(@subject.available_mime_types.to_a).to eql([])
      end
      it "returns an empty array if :output_type has no mime_types defined" do
        @subject.physical_object!
        expect(@subject.available_mime_types.to_a).to eql([])
      end
      it "returns the correct mime_types for :output_type == :audiovisual" do
        @subject.audiovisual!
        expect(@subject.available_mime_types.to_a).to eql(@audiovisuals)
      end
      it "returns the correct mime_types for :output_type == :sound" do
        @subject.sound!
        expect(@subject.available_mime_types.to_a).to eql(@audiovisuals)
      end
      it "returns the correct mime_types for :output_type == :image" do
        @subject.image!
        expect(@subject.available_mime_types.to_a).to eql(@images)
      end
      it "returns the correct mime_types for :output_type == :data_paper" do
        @subject.data_paper!
        expect(@subject.available_mime_types.to_a).to eql(@texts)
      end
      it "returns the correct mime_types for :output_type == :dataset" do
        @subject.dataset!
        expect(@subject.available_mime_types.to_a).to eql(@texts)
      end
      it "returns the correct mime_types for :output_type == :text" do
        @subject.text!
        expect(@subject.available_mime_types.to_a).to eql(@texts)
      end
      it "returns the correct mime_types for :output_type == :model_representation" do
        @subject.model_representation!
        expect(@subject.available_mime_types.to_a).to eql(@models)
      end
    end

    xit "licenses should have tests once implemented" do
      true
    end
    xit "repositories should have tests once implemented" do
      true
    end
    xit "metadata_standards should have tests once implemented" do
      true
    end
    xit "resource_types should have tests once implemented" do
      true
    end
  end

end
