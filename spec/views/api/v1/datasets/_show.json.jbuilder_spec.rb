# frozen_string_literal: true

require "rails_helper"

describe "api/v1/datasets/_show.json.jbuilder" do

  before(:each) do
    # TODO: Implement this once the Dataset models are in place
    @plan = create(:plan)
    @output = create(:research_output, plan: @plan)
    render partial: "api/v1/datasets/show", locals: { output: @output }
    @json = JSON.parse(rendered).with_indifferent_access
  end

  describe "includes all of the dataset attributes" do
    it "includes :type" do
      expect(@json[:type]).to eql(@output.output_type)
    end
    it "includes :title" do
      expect(@json[:title]).to eql(@output.title)
    end
    it "includes :description" do
      expect(@json[:description]).to eql(@output.description)
    end
    it "includes :personal_data" do
      expected = Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: @output.personal_data)
      expect(@json[:personal_data]).to eql(expected)
    end
    it "includes :sensitive_data" do
      expected = Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: @output.personal_data)
      expect(@json[:sensitive_data]).to eql(expected)
    end
    it "includes :issued" do
      expect(@json[:issued]).to eql(@output.release_date&.to_formatted_s(:iso8601))
    end
    it "includes :dataset_id" do
      expect(@json[:dataset_id][:type]).to eql("other")
      expect(@json[:dataset_id][:identifier]).to eql(@output.id.to_s)
    end
    context ":distribution info" do
      before(:each) do
        @distribution = @json[:distribution].first
      end
      it "includes :byte_size" do
        expect(@distribution[:byte_size]).to eql(@output.byte_size)
      end
      it "includes :data_access" do
        expect(@distribution[:data_access]).to eql(@output.access)
      end
      it "includes :format" do
        expect(@distribution[:format]).to eql(@output.mime_type&.value)
      end
    end
    it "includes :metadata" do
      expect(@json[:metadata]).to eql([])
    end
    it "includes :technical_resources" do
      expect(@json[:technical_resources]).to eql([])
    end
  end

  describe "includes all of the repository info as attributes" do
    before(:each) do
      @host = @json[:distribution].first[:host]
      @expected = @output.repositories.last
    end
    it "includes :title" do
      expect(@host[:title]).to eql(@expected.name)
    end
    it "includes :description" do
      expect(@host[:description]).to eql(@expected.description)
    end
    it "includes :url" do
      expect(@host[:url]).to eql(@expected.url)
    end
    it "includes :dmproadmap_host_id" do
      expect(@host[:dmproadmap_host_id][:type]).to eql(@expected.identifiers.last&.identifier_format)
      expect(@host[:dmproadmap_host_id][:identifier]).to eql(@expected.identifiers.last&.value)
    end
  end

  describe "includes all of the themed question/answers as attributes" do
    it "includes :preservation_statement" do
      expect(@json[:preservation_statement]).to eql("")
    end
    it "includes :security_and_privacy" do
      expect(@json[:security_and_privacy]).to eql([])
    end
    it "includes :data_quality_assurance" do
      expect(@json[:data_quality_assurance]).to eql("")
    end
  end

end
