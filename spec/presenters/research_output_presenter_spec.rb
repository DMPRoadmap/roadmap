# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResearchOutputPresenter do

  before(:each) do
    @research_output = create(:research_output, plan: create(:plan))
    @presenter = described_class.new(research_output: @research_output)
  end

  describe ":selectable_output_types" do
    it "returns the output types" do
      expect(@presenter.selectable_output_types.any?).to eql(true)
    end
    it "packages the output types for a selectbox - [['Audiovisual', 'audiovisual']]" do
      sample = @presenter.selectable_output_types.first
      expect(sample.length).to eql(2)
      expect(sample[0].scan(/^[a-zA-Z\s]*$/).any?).to eql(true)
      expect(sample[1].scan(/^[a-z]*$/).any?).to eql(true)
      expect(sample[0].underscore).to eql(sample[1])
      expect(ResearchOutput.output_types[sample[1]].present?).to eql(true)
    end
  end

  describe ":selectable_access_types" do
    it "returns the output types" do
      expect(@presenter.selectable_access_types.any?).to eql(true)
    end
    it "packages the output types for a selectbox - [['Open', 'open']]" do
      sample = @presenter.selectable_access_types.first
      expect(sample.length).to eql(2)
      expect(sample[0].scan(/^[a-zA-Z\s]*$/).any?).to eql(true)
      expect(sample[1].scan(/^[a-z]*$/).any?).to eql(true)
      expect(sample[0].underscore).to eql(sample[1])
      expect(ResearchOutput.accesses[sample[1]].present?).to eql(true)
    end
  end

  describe ":selectable_size_units" do
    it "returns the output types" do
      expect(@presenter.selectable_size_units.any?).to eql(true)
    end
    it "packages the output types for a selectbox - [['MB', 'mb']]" do
      sample = @presenter.selectable_size_units.first
      expect(sample.length).to eql(2)
      expect(sample[0].scan(/^[a-zA-Z\s]*$/).any?).to eql(true)
      expect(sample[1].scan(/^[a-z]*$/).any?).to eql(true)
      expect(sample[0].downcase).to eql(sample[1])
    end
  end

  describe ":converted_file_size(size:)" do
    it "returns an zero MB if size is not present" do
      expect(@presenter.converted_file_size(size: nil)).to eql({ size: nil, unit: "mb" })
    end
    it "returns an zero MB if size is not a number" do
      expect(@presenter.converted_file_size(size: "foo")).to eql({ size: nil, unit: "mb" })
    end
    it "returns an zero MB if size is not positive" do
      expect(@presenter.converted_file_size(size: -1)).to eql({ size: nil, unit: "mb" })
    end
    it "can handle bytes" do
      expect(@presenter.converted_file_size(size: 100)).to eql({ size: 100, unit: "" })
    end
    it "can handle megabytes" do
      expect(@presenter.converted_file_size(size: 1.megabytes)).to eql({ size: 1, unit: "mb" })
    end
    it "can handle gigabytes" do
      expect(@presenter.converted_file_size(size: 1.gigabytes)).to eql({ size: 1, unit: "gb" })
    end
    it "can handle terabytes" do
      expect(@presenter.converted_file_size(size: 1.terabytes)).to eql({ size: 1, unit: "tb" })
    end
    it "can handle petabytes" do
      expect(@presenter.converted_file_size(size: 1.petabytes)).to eql({ size: 1, unit: "pb" })
    end
  end

  describe ":display_name" do
    it "returns an empty string unless if we do not have a ResearchOutput" do
      presenter = described_class.new(research_output: build(:org))
      expect(presenter.display_name).to eql("")
    end
    it "does not trim names that are <= 50 characters" do
      presenter = described_class.new(research_output: build(:research_output, title: "a" * 49))
      expect(presenter.display_name).to eql("a" * 49)
    end
    it "does not trims names that are > 50 characters" do
      presenter = described_class.new(research_output: build(:research_output, title: "a" * 51))
      expect(presenter.display_name).to eql("#{'a' * 50} ...")
    end
  end

  describe ":display_type" do

  end

  describe ":display_repository" do

  end

  describe ":display_access" do

  end

  describe ":display_release" do

  end

  context "class methods" do
    describe ":selectable_subjects" do
      it "returns subjects" do
        expect(described_class.selectable_subjects.any?).to eql(true)
      end
      it "packages the subjects for a selectbox - [['Biology', '21 Biology']]" do
        sample = described_class.selectable_subjects.first
        expect(sample.length).to eql(2)
        expect(sample[0].scan(/^[a-zA-Z\s\,]*$/).any?).to eql(true)
        expect(sample[1].scan(/^[0-9]+\s[a-zA-Z\s\,]*$/).any?).to eql(true)
        expect(sample[1].ends_with?(sample[0])).to eql(true)
      end
    end

    describe ":selectable_repository_types" do
      it "returns repository types" do
        expect(described_class.selectable_repository_types.any?).to eql(true)
      end
      it "packages the repository types for a selectbox - [['Discipline specific', 'disciplinary']]" do
        sample = described_class.selectable_repository_types.first
        expect(sample.length).to eql(2)
        expect(sample[0].scan(/^[A-Z]{1}[a-z\s\(\)]*$/).any?).to eql(true)
        expect(sample[1].scan(/^[a-z]*$/).any?).to eql(true)
      end
    end
  end

end