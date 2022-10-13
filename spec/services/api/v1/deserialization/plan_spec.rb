# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Deserialization::Plan do
  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, abbreviation: 'v1-plan', default_language: true) unless Language.default

    @template = create(:template)
    @plan = create(:plan, template: @template, org: create(:org))
    @scheme = create(:identifier_scheme, name: 'doi',
                                         identifier_prefix: Faker::Internet.url)
    @doi = '10.9999/45ty5t.345/34t'
    @identifier = create(:identifier, identifier_scheme: @scheme,
                                      identifiable: @plan, value: @doi)

    @app_name = ApplicationService.application_name.split('-').first&.downcase
    @app_name = 'tester' unless @app_name.present?

    contrib = Contributor.new
    @json = {
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.paragraph,
      ethical_issues_exist: 'unknown',
      contact: {
        name: Faker::Movies::StarWars.character,
        mbox: Faker::Internet.email
      },
      contributor: [
        {
          name: Faker::TvShows::Simpsons.unique.character,
          role: ["#{Contributor::ONTOLOGY_BASE_URL}/#{contrib.all_roles.first}"]
        },
        {
          name: Faker::TvShows::Simpsons.unique.character,
          role: [contrib.all_roles.last.to_s]
        }
      ],
      project: [
        {
          title: Faker::Lorem.sentence,
          description: Faker::Lorem.paragraph,
          start: Time.now.to_formatted_s(:iso8601),
          end: (Time.now + 2.years).to_formatted_s(:iso8601),
          funding: [
            { name: create(:org, name: Faker::Movies::StarWars.planet).name }
          ]
        }
      ],
      dataset: [
        { title: Faker::Lorem.sentence }
      ],
      dmp_id: { type: 'doi', identifier: @identifier.value },
      extension: [
        dmproadmap: {
          template: { id: @template.id, title: @template.title }
        }
      ]
    }

    # We need to ensure that the deserializer on Funding is called, but
    # no need to check that class' subsequent calls
    Api::V1::Deserialization::Org.stubs(:deserialize!).returns(@org)
    Api::V1::Deserialization::Identifier.stubs(:deserialize!).returns(@identifier)
  end

  describe '#deserialize!(json: {})' do
    before(:each) do
      described_class.stubs(:find_or_initialize).returns(@plan)
      described_class.stubs(:deserialize_project).returns(@plan)
      described_class.stubs(:deserialize_contact).returns(@plan)
      described_class.stubs(:deserialize_contributors).returns(@plan)
      described_class.stubs(:deserialize_datasets).returns(@plan)
    end

    it 'returns nil if json is not valid' do
      expect(described_class.deserialize(json: nil)).to eql(nil)
    end
    it 'returns nil if no :dmp_id, :template or default template available' do
      @plan.template = nil
      described_class.stubs(:find_or_initialize).returns(@plan)
      expect(described_class.deserialize(json: @json)).to eql(nil)
    end
    it 'returns the Plan' do
      expect(described_class.deserialize(json: @json)).to eql(@plan)
    end
    it 'sets the title' do
      result = described_class.deserialize(json: @json)
      expect(result.title).to eql(@plan.title)
    end
    it 'sets the description' do
      result = described_class.deserialize(json: @json)
      expect(result.description).to eql(@plan.description)
    end
  end

  context 'private methods' do
    describe ':find_or_initialize(id_json:, json: {})' do
      it 'returns nil if json is not present' do
        result = described_class.send(:find_or_initialize, id_json: nil, json: nil)
        expect(result).to eql(nil)
      end
      it 'returns a the existing Plan when :dmp_id is one of our DOIs' do
        Api::V1::DeserializationService.expects(:object_from_identifier).returns(@plan)
        result = described_class.send(:find_or_initialize, id_json: @json[:dmp_id], json: @json)
        expect(result).to eql(@plan)
        expect(result.new_record?).to eql(false)
        expect(result.title).to eql(@plan.title)
      end
      it 'returns a the existing Plan when the :dmp_id is one of our URLs' do
        @json[:dmp_id] = {
          type: 'URL', identifier: Rails.application.routes.url_helpers.plan_url(@plan)
        }
        result = described_class.send(:find_or_initialize, id_json: @json[:dmp_id], json: @json)
        expect(result).to eql(@plan)
        expect(result.new_record?).to eql(false)
        expect(result.title).to eql(@plan.title)
      end
      it 'initializes the Plan if the :dmp_id had no matches' do
        @json[:dmp_id] = { type: 'URL', identifier: Faker::Internet.url }
        result = described_class.send(:find_or_initialize, id_json: @json[:dmp_id], json: @json)
        expect(result).not_to eql(@plan)
        expect(result.new_record?).to eql(true)
        expect(result.title).to eql(@json[:title])
      end
      it 'initializes the Plan if there were no viable matches' do
        json = {
          title: Faker::Lorem.sentence,
          contact: { email: Faker::Internet.email }
        }
        result = described_class.send(:find_or_initialize, id_json: nil, json: json)
        expect(result.new_record?).to eql(true)
        expect(result.title).to eql(json[:title])
      end
    end

    describe '#deserialize_project(plan:, json:)' do
      before(:each) do
        # clear out the dates set in the factory
        @plan.start_date = nil
        @plan.end_date = nil
      end

      it 'returns the Plan as-is if the json is not present' do
        result = described_class.send(:deserialize_project, plan: @plan, json: nil)
        expect(result).to eql(@plan)
        expect(result.start_date).to eql(nil)
      end
      it 'returns the Plan as-is if the json :project is not present' do
        json = { title: Faker::Lorem.sentence }
        result = described_class.send(:deserialize_project, plan: @plan, json: json)
        expect(result).to eql(@plan)
        expect(result.start_date).to eql(nil)
      end
      it 'returns the Plan as-is if the json :project is not an array' do
        json = {
          title: Faker::Lorem.sentence,
          project: { start: Time.now.to_formatted_s(:iso8601) }
        }
        result = described_class.send(:deserialize_project, plan: @plan, json: json)
        expect(result).to eql(@plan)
        expect(result.start_date).to eql(nil)
      end
      it 'assigns the start_date of the Plan' do
        result = described_class.send(:deserialize_project, plan: @plan, json: @json)
        expected = Time.parse(@json[:project].first[:start]).utc.to_formatted_s(:iso8601)
        expect(result.start_date.to_formatted_s(:iso8601)).to eql(expected)
      end
      it 'assigns the end_date of the Plan' do
        result = described_class.send(:deserialize_project, plan: @plan, json: @json)
        expected = Time.parse(@json[:project].first[:end]).utc.to_formatted_s(:iso8601)
        expect(result.end_date.to_formatted_s(:iso8601)).to eql(expected)
      end
      it 'does not call the deserializer for Funding if :funding is not present' do
        @json[:project].first[:funding] = nil
        Api::V1::Deserialization::Funding.expects(:deserialize).at_most(0)
        described_class.send(:deserialize_project, plan: @plan, json: @json)
      end
      it 'calls the deserializer for Funding if :funding present' do
        Api::V1::Deserialization::Funding.expects(:deserialize).at_least(1)
        described_class.send(:deserialize_project, plan: @plan, json: @json)
      end
    end

    describe '#deserialize_contact(plan:, json:)' do
      it 'returns the Plan as-is if json is not present' do
        result = described_class.send(:deserialize_contact, plan: @plan, json: nil)
        expect(result).to eql(@plan)
        expect(result.contributors.length).to eql(0)
      end
      it 'returns the Plan as-is if json :contact is not present' do
        @json[:contact] = nil
        result = described_class.send(:deserialize_contact, plan: @plan, json: @json)
        expect(result).to eql(@plan)
        expect(result.contributors.length).to eql(0)
      end
      it 'calls the Contributor.deserialize! for the contact entry' do
        Api::V1::Deserialization::Contributor.expects(:deserialize).at_least(1)
        described_class.send(:deserialize_contact, plan: @plan, json: @json)
      end
      it "attaches the Contact to the Plan's contributors" do
        result = described_class.send(:deserialize_contact, plan: @plan, json: @json)
        expect(result.contributors.length).to eql(1)
        expect(result.contributors.first.name).to eql(@json[:contact][:name])
      end
    end

    describe '#deserialize_contributors(plan:, json:)' do
      it 'calls the Contributor.deserialize for each contributor entry' do
        Api::V1::Deserialization::Contributor.expects(:deserialize).at_least(2)
        described_class.send(:deserialize_contributors, plan: @plan, json: @json)
      end
      it 'attaches the Contributors to the Plan' do
        result = described_class.send(:deserialize_contributors, plan: @plan,
                                                                 json: @json)
        expect(result.contributors.length).to eql(2)
        expect(result.contributors.first.name).to eql(@json[:contributor].first[:name])
        expect(result.contributors.last.name).to eql(@json[:contributor].last[:name])
      end
    end

    describe '#find_template(json:)' do
      it 'returns nil if the json is not present' do
        expect(described_class.send(:find_template, json: nil)).to eql(nil)
      end
      it 'returns default template if no template is found for the :id' do
        json = { template: { id: 9999, title: Faker::Lorem.sentence } }
        expect(described_class.send(:find_template, json: json)).to eql(nil)
      end
      it 'returns the specified template' do
        expect(described_class.send(:find_template, json: @json)).to eql(@template)
      end
    end

    describe 'template_id(json:)' do
      it 'returns nil if json not present' do
        expect(described_class.send(:template_id, json: nil)).to eql(nil)
      end
      it 'returns nil if extensions for the app were not found' do
        Api::V1::DeserializationService.stubs(:app_extensions).returns({})
        expect(described_class.send(:template_id, json: @json)).to eql(nil)
      end
      it 'returns nil if the extensions have no template info' do
        expected = { foo: { title: Faker::Lorem.sentence } }
        Api::V1::DeserializationService.stubs(:app_extensions).returns(expected)
        expect(described_class.send(:template_id, json: @json)).to eql(nil)
      end
      it 'returns nil if the extensions have no id for the template info' do
        expected = { template: { title: Faker::Lorem.sentence } }
        Api::V1::DeserializationService.stubs(:app_extensions).returns(expected)
        expect(described_class.send(:template_id, json: @json)).to eql(nil)
      end
      it 'returns the template id' do
        expect(described_class.send(:template_id, json: @json)).to eql(@template.id)
      end
    end
  end
end
