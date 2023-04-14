# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::Deserialization::Dataset do
  before do
    # Org requires a language, so make sure a default is available!
    @plan = create(:plan)
    @research_output = create(:research_output, plan: @plan)

    @json = {
      type: ResearchOutput.output_types.keys.sample,
      title: @research_output.title,
      description: Faker::Lorem.paragraph,
      personal_data: %w[yes no unknown].sample,
      sensitive_data: %w[yes no unknown].sample,
      issued: 1.year.from_now.to_formatted_s(:iso8601),
      preservation_statement: Faker::Lorem.paragraph,
      security_and_privacy: [
        {
          title: Faker::Lorem.sentence,
          description: [Faker::Lorem.paragraph]
        }
      ],
      data_quality_assurance: Faker::Lorem.paragraph,
      dataset_id: { type: 'other', identifier: @research_output.id.to_s },
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
              start_date: 6.months.from_now.to_formatted_s(:iso8601)
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
  end

  describe ':deserialize(json: {})' do
    it 'returns nil if json is not valid' do
      Api::V2::JsonValidationService.stubs(:dataset_valid?).returns(false)
      expect(described_class.deserialize(plan: @plan, json: nil)).to be_nil
    end

    it 'return nil if :find_or_initialize does not return a ResearchOutput' do
      described_class.stubs(:find_by_identifier).returns(nil)
      described_class.stubs(:find_or_initialize).returns(nil)
      expect(described_class.deserialize(plan: @plan, json: @json)).to be_nil
    end

    context 'initializes' do
      before do
        described_class.stubs(:attach_metadata).returns(@research_output)
        described_class.stubs(:deserialize_distribution).returns(@research_output)
      end

      it 'updates the expected attributes for a ResearchOutput' do
        described_class.stubs(:find_by_identifier).returns(@research_output)
        result = described_class.deserialize(plan: @plan, json: @json)
        expect(result.description).to eql(@json[:description])
        expected = Api::V2::ConversionService.yes_no_unknown_to_boolean(@json[:personal_data])
        expect(result.personal_data).to eql(expected)
        expected = Api::V2::ConversionService.yes_no_unknown_to_boolean(@json[:sensitive_data])
        expect(result.sensitive_data).to eql(expected)
        expect(result.release_date).to eql(Time.zone.parse(@json[:issued]))
      end
    end
  end

  context 'private methods' do
    describe ':find_by_identifier(plan:, json: {})' do
      it 'returns nil if json is not present' do
        expect(described_class.send(:find_by_identifier, plan: @plan, json: nil)).to be_nil
      end

      it 'finds the ResearchOutput by :dataset_id' do
        Api::V2::DeserializationService.stubs(:dmp_id?).returns(false)
        result = described_class.send(:find_by_identifier, plan: @plan, json: @json[:dataset_id])
        expect(result).to eql(@research_output)
      end

      it 'does not change the :output_type of an existing ResearchOutput' do
        Api::V2::DeserializationService.stubs(:dmp_id?).returns(false)
        @json[:type] = ResearchOutput.output_types.keys.reject do |key|
          key == @research_output.research_output_type
        end.sample
        result = described_class.send(:find_by_identifier, plan: @plan, json: @json[:dataset_id])
        expect(result.new_record?).to be(false)
        expect(result.research_output_type).to eql(@research_output.research_output_type)
      end

      it 'does not initialize a new ResearchOutput' do
        Api::V2::DeserializationService.stubs(:dmp_id?).returns(false)
        @json[:dataset_id][:identifier] = Faker::Music::PearlJam.song
        expect(described_class.send(:find_by_identifier, plan: @plan, json: @json[:dataset_id])).to be_nil
      end
    end

    describe ':find_or_initialize(plan:, json: {})' do
      it 'returns nil if json is not present' do
        expect(described_class.send(:find_or_initialize, plan: @plan, json: nil)).to be_nil
      end

      it 'finds the ResearchOutput by :plan and :title' do
        expect(described_class.send(:find_or_initialize, plan: @plan, json: @json)).to eql(@research_output)
      end

      it 'does not change the :output_type of an existing ResearchOutput' do
        @json[:type] = ResearchOutput.output_types.keys.reject do |key|
          key == @research_output.research_output_type
        end.sample
        result = described_class.send(:find_or_initialize, plan: @plan, json: @json)
        expect(result.new_record?).to be(false)
        expect(result.research_output_type).to eql(@research_output.research_output_type)
      end

      it 'initializes a new ResearchOutput' do
        @json[:title] = Faker::Music::PearlJam.unique.song
        result = described_class.send(:find_or_initialize, plan: @plan, json: @json)
        expect(result.new_record?).to be(true)
        expect(result.title).to eql(@json[:title])
        expect(result.plan).to eql(@plan)
        expect(result.research_output_type).to eql(@json[:type])
      end
    end

    describe ':attach_metadata(research_output:, json:)' do
      before do
        @research_output.metadata_standards.clear
      end

      it 'returns the ResearchOutput as-is if json is not an Array' do
        result = described_class.send(:attach_metadata, research_output: @research_output, json: nil)
        expect(result).to eql(@research_output)
      end

      it 'skips entries that have no :metadata_standard_id' do
        @json[:metadata] = @json[:metadata].map { |hash| hash.delete(:metadata_standard_id) }
        result = described_class.send(:attach_metadata, research_output: @research_output, json: @json[:metadata])
        expect(result.metadata_standards.length).to be(0)
      end

      it 'skips entries that have no matching entry ion the MetadataStandard table' do
        MetadataStandard.all.destroy_all
        result = described_class.send(:attach_metadata, research_output: @research_output, json: @json[:metadata])
        expect(result.metadata_standards.length).to be(0)
      end

      it 'skips entries that are already attached to the ResearchOutput' do
        hash = @json[:metadata].first
        standard = create(:metadata_standard, uri: hash[:metadata_standard_id][:identifier],
                                              description: hash[:description])
        @research_output.metadata_standards << standard
        result = described_class.send(:attach_metadata, research_output: @research_output, json: @json[:metadata])
        expect(result.metadata_standards.count { |s| s.uri == standard.uri }).to be(1)
      end

      it 'adds the :metadata_standard' do
        standards = @json[:metadata].map do |hash|
          create(:metadata_standard, uri: hash[:metadata_standard_id][:identifier],
                                     description: hash[:description])
        end
        result = described_class.send(:attach_metadata, research_output: @research_output, json: @json[:metadata])
        expect(result.metadata_standards.length).to eql(standards.length)
        standards.each { |ms| expect(result.metadata_standards.include?(ms)).to be(true) }
      end
    end

    describe ':deserialize_distribution(research_output:, json:)' do
      before do
        @research_output.repositories.clear
        @research_output.license = nil
        described_class.stubs(:attach_repositories).returns(@research_output)
        described_class.stubs(:attach_licenses).returns(@research_output)
      end

      it 'returns the ResearchOutput as-is if json is not an Array' do
        result = described_class.send(:deserialize_distribution, research_output: @research_output, json: nil)
        expect(result).to eql(@research_output)
      end

      it 'adds the distribution data to the ResearchOutput' do
        json = @json[:distribution]
        result = described_class.send(:deserialize_distribution, research_output: @research_output, json: json)
        expect(result.byte_size).to eql(json.first[:byte_size])
        expect(result.access).to eql(json.first[:data_access])
      end
    end

    describe ':attach_repositories(research_output:, json:)' do
      before do
        Repository.all.destroy_all
        @research_output.repositories.clear
        @repository = create(:repository)
        @identifier = create(:identifier, identifiable: @repository)
        @repository.reload
      end

      it 'returns the ResearchOutput as-is if json is not an Array' do
        result = described_class.send(:attach_repositories, research_output: @research_output, json: nil)
        expect(result.repositories.length).to be(0)
      end

      it 'returns the ResearchOutput as-is if json does not define a :url or :dmproadmap_host_id' do
        json = { title: @repository.name, description: @repository.description }
        result = described_class.send(:attach_repositories, research_output: @research_output, json: json)
        expect(result.repositories.length).to be(0)
      end

      it 'returns the ResearchOutput as-is if the ResearchOutput already has the Repository' do
        @research_output.repositories << @repository
        json = { title: @repository.name, description: @repository.description, url: @repository.homepage }
        result = described_class.send(:attach_repositories, research_output: @research_output, json: json)
        expect(result.repositories.length).to be(1)
      end

      it 'finds the Repository by :url and attaches it to the ResearchOutput' do
        json = { title: @repository.name, description: @repository.description, url: @repository.homepage }
        result = described_class.send(:attach_repositories, research_output: @research_output, json: json)
        expect(result.repositories.length).to be(1)
        expect(result.repositories.first).to eql(@repository)
      end

      it 'finds the Repository by :dmproadmap_host_id and attaches it to the ResearchOutput' do
        json = {
          description: @repository.description,
          url: @repository.homepage,
          dmproadmap_host_id: { type: 'url', identifier: @identifier.value }
        }
        result = described_class.send(:attach_repositories, research_output: @research_output, json: json)
        expect(result.repositories.length).to be(1)
        expect(result.repositories.first).to eql(@repository)
      end
    end

    describe ':attach_licenses(research_output:, json:)' do
      before do
        License.all.destroy_all
        @research_output.license = nil
        @license = create(:license)
      end

      it 'returns the ResearchOutput as-is if json is not an Array' do
        result = described_class.send(:attach_licenses, research_output: @research_output, json: nil)
        expect(result.license).to be_nil
      end

      it 'returns the ResearchOutput as-is if none of the licenses are defined in the License table' do
        result = described_class.send(:attach_licenses, research_output: @research_output,
                                                        json: @json[:distribution].first)
        expect(result.license).to be_nil
      end

      it 'attaches the first license (by release_date) if none are current' do
        json = [
          { license_ref: @license.uri, start_date: 6.months.from_now.to_formatted_s(:iso8601) },
          { license_ref: Faker::Internet.url, start_date: 7.months.from_now.to_formatted_s(:iso8601) }
        ]
        result = described_class.send(:attach_licenses, research_output: @research_output, json: json)
        expect(result.license).to eql(@license)
      end

      it 'attaches the current license (by release_date)' do
        json = [
          { license_ref: Faker::Internet.url, start_date: 6.months.ago.to_formatted_s(:iso8601) },
          { license_ref: @license.uri, start_date: 2.months.ago.to_formatted_s(:iso8601) }
        ]
        result = described_class.send(:attach_licenses, research_output: @research_output, json: json)
        expect(result.license).to eql(@license)
      end
    end
  end
end
