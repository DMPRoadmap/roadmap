# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::DatasetsController, type: :request do

  include Api::AccessTokenRequestHelper
  include Api::AuthorizationRequestHelper
  include Api::RequestSpecHelper

  before(:each) do
    @plan = create(:plan, :creator)
    client_is_authorized(create(:api_client), @plan.owner, { scopes: "create_dmps" })
    i_am_logged_in
    resource_owner_is_authenticated(@plan.owner)
  end

  describe "POST /api/v2/plans/[:id]/datasets - create" do
    before(:each) do
      @dataset_json = {
        type: ResearchOutput.output_types.keys.sample,
        title: Faker::Music::PearlJam.unique.song,
        description: Faker::Lorem.paragraph,
        personal_data: %w[yes no unknown].sample,
        sensitive_data: %w[yes no unknown].sample,
        issued: (Time.now + 1.years).to_formatted_s(:iso8601),
        preservation_statement: Faker::Lorem.paragraph,
        security_and_privacy: [
          {
            title: Faker::Lorem.sentence,
            description: [Faker::Lorem.paragraph]
          },
        ],
        data_quality_assurance: Faker::Lorem.paragraph,
        dataset_id: { type: "other", identifier: SecureRandom.uuid },
        distribution: [
          {
            title: Faker::Lorem.sentence,
            byte_size: Faker::Number.number(digits: 7),
            data_access: ResearchOutput.accesses.keys.sample,
            host: {
              title: Faker::Lorem.sentence,
              description: Faker::Lorem.paragraph,
              url: Faker::Internet.url,
              dmproadmap_host_id: { type: Faker::Lorem.word, identifier: SecureRandom.uuid }
            },
            license: [
              {
                license_ref: Faker::Internet.url,
                start_date: (Time.now + 6.months).to_formatted_s(:iso8601)
              }
            ]
          }
        ],
        metadata: [
          {
            description: Faker::Lorem.paragraph,
            metadata_standard_id: { type: Faker::Lorem.word, identifier: SecureRandom.uuid }
          }
        ],
        technical_resource: []
      }
      @json = { items: { dmp: { dataset: [@dataset_json] } } }
    end

    it "returns a 401 if the request is unauthorized" do
      post api_v2_datasets_path(@plan), params: @json.to_json
      expect(response.code).to eql("401")
      expect(response).to render_template("api/v2/error")
    end
    it "returns a 400 if the incoming JSON is invalid" do
      post api_v2_datasets_path(@plan), params: Faker::Lorem.word
      expect(response.code).to eql("400")
      expect(response).to render_template("api/v2/error")
    end
    it "returns a 400 if the incoming DMP is invalid" do
      @json[:items].first[:dmp][:dataset].first.delete(:title)
      @json[:items].first[:dmp][:dataset].first.delete(:dataset_id)
      post api_v2_datasets_path(@plan), params: @json.to_json
      expect(response.code).to eql("400")
      expect(response).to render_template("api/v2/error")
    end
    it "skips datasets that already exist" do
      research_output = create(:research_output, title: @dataset_json[:title])
      identifier = create(:identifier, identifiable: research_output, value: @dataset_json[:dataset_id][:identifier])
      @plan.reload
      post api_v2_datasets_path(@plan), params: @json.to_json
      expect(response.code).to eql("400")
      expect(response).to render_template("api/v2/error")
      expect(response.body.include?("already exists")).to eql(true)
    end
    it "returns a 201 if the incoming JSON is valid" do
      post api_v2_datasets_path(@plan), params: @json.to_json
      expect(response.code).to eql("201")
      expect(response).to render_template("api/v2/plans/show")
    end

    context "ResearchOutput inspection" do
      before(:each) do
        post api_v2_datasets_path(@plan), params: @json.to_json
        @research_output = ResearchOutput.last
      end

      it "set the dataset fields" do
        expect(@research_output.title).to eql(@dataset_json[:title])
        expect(@research_output.description).to eql(@dataset_json[:description])
        expect(@research_output.personal_data).to eql(Api::V1::ConversionService.yes_no_unknown_to_boolean(@dataset_json[:personal_data]))
        expect(@research_output.sensitive_data).to eql(Api::V1::ConversionService.yes_no_unknown_to_boolean(@dataset_json[:sensitive_data]))
        expect(@research_output.release_date).to eql(Time.parse(@dataset_json[:issued]))
      end
      it "set the distribution fields" do
        expect(@research_output.byte_size).to eql(Time.parse(@dataset_json[:distribution].last[:byte_size]))
        expect(@research_output.access).to eql(Time.parse(@dataset_json[:distribution].last[:data_access]))
      end
      it "attached the Identifier" do
        identifier = @research_output.identifiers.last
        expect(@research_output.identifiers.length).to eql(1)
        expect(identifier.value).to eql(@dataset_json[:dataset_id][:identifier])
      end
      it "attached the Repository" do
        repo = @research_output.repositories.last
        id = repo.identifiers.last
        expect(@research_output.repositories.length).to eql(@dataset_json[:distribution].length)
        expect(repo.url).to eql(@dataset_json[:distribution][:host][:url])
        expect(id.value).to eql(@dataset_json[:distribution][:host][:dmproadmap_host_id][:identifier])
      end
      it "attached the License" do
        expected = @dataset_json[:distribution].last[:license].last[:license_ref]
        expect(@research_output.license.url).to eql(expected)
      end
      it "attached the MetadataStandard" do
        standard = @research_output.metadata_standards.last
        expect(@research_output.metadata_standards.length).to eql(@dataset_json[:metadata].length)
        expect(standard.url).to eql(@dataset_json[:metadata].last[:metadata_standard_id][:identifier])
      end
    end

  end

end
