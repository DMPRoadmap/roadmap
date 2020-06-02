# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Deserialization::Plan do

  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, default_language: true) unless Language.default

    @template = create(:template)
    @plan = create(:plan, template: @template)
    @scheme = create(:identifier_scheme, name: "doi",
                                         identifier_prefix: Faker::Internet.url)
    @doi = "10.9999/45ty5t.345/34t"
    @identifier = create(:identifier, identifier_scheme: @scheme,
                                      identifiable: @plan, value: @doi)

    @app_name = ApplicationService.application_name.split("-").first&.downcase
    @app_name = "tester" unless @app_name.present?

    contrib = Contributor.new
    @json = {
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.paragraph,
      ethical_issues_exist: "unknown",
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
            { name: Faker::Movies::StarWars.planet }
          ]
        }
      ],
      dataset: [
        { title: Faker::Lorem.sentence }
      ],
      dmp_id: { type: "doi", identifier: @identifier.value },
      extension: [
        "#{@app_name}": {
          template: { id: @template.id, title: @template.title }
        }
      ]
    }

    # We need to ensure that the deserializer on Funding is called, but
    # no need to check that class' subsequent calls
    Api::V1::Deserialization::Org.stubs(:deserialize!).returns(@org)
    Api::V1::Deserialization::Identifier.stubs(:deserialize!).returns(@identifier)
  end

  describe "#deserialize!(json: {})" do
    before(:each) do
      described_class.stubs(:marshal_plan).returns(@plan)
      described_class.stubs(:deserialize_project).returns(@plan)
      described_class.stubs(:deserialize_contact).returns(@plan)
      described_class.stubs(:deserialize_contributors).returns(@plan)
      described_class.stubs(:deserialize_datasets).returns(@plan)
    end

    it "returns nil if json is not valid" do
      expect(described_class.deserialize!(json: nil)).to eql(nil)
    end
    it "returns nil if no :dmp_id, :template or default template available" do
      described_class.stubs(:marshal_plan).returns(nil)
      described_class.deserialize!(json: @json)
    end
    it "returns the Plan" do
      expect(described_class.deserialize!(json: @json)).to eql(@plan)
    end
    it "sets the title to the default" do
      described_class.stubs(:marshal_plan).returns(Plan.new)
      result = described_class.deserialize!(json: @json)
      expect(result.title).to eql(@plan.title)
    end
    it "sets the description" do
      described_class.stubs(:marshal_plan).returns(Plan.new)
      result = described_class.deserialize!(json: @json)
      expect(result.description).to eql(@plan.description)
    end
  end

  context "private methods" do

    describe "#valid?(json:)" do
      it "returns false if json is not present" do
        expect(described_class.send(:valid?, json: nil)).to eql(false)
      end
      it "returns false if :name is not present" do
        json = { abbreviation: @abbrev }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it "returns false if no default template, no :template and no :dmp_id" do
        Template.find_by(is_default: true)&.destroy
        @json[:dmp_id] = nil
        @json[:extension] = []
        expect(described_class.send(:valid?, json: @json)).to eql(false)
      end
      it "returns true" do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
    end

    describe "#marshal_plan(json:)" do
      it "returns nil if json is not present" do
        expect(described_class.send(:marshal_plan, json: nil)).to eql(nil)
      end
      it "returns nil there is no :dmp_id and no :template" do
        @json[:dmp_id] = nil
        @json[:extension] = []
        expect(described_class.send(:marshal_plan, json: @json)).to eql(nil)
      end
      it "returns nil if :dmp_id was not found, no :template, no default template" do
        @json[:dmp_id][:identifier] = SecureRandom.uuid
        @json[:extension] = []
        expect(described_class.send(:marshal_plan, json: @json)).to eql(nil)
      end
      it "finds the Plan by :dmp_id" do
        expect(described_class.send(:marshal_plan, json: @json)).to eql(@plan)
      end
      it "creates a new Plan with default template if no :dmp_id and no :template" do
        @json[:dmp_id] = []
        @json[:extension] = []
        default = Template.find_by(is_default: true)
        default = create(:template, is_default: true) unless default.present?
        result = described_class.send(:marshal_plan, json: @json)
        expect(result.new_record?).to eql(true)
        expect(result.template_id).to eql(default.id)
      end
      it "creates a new Plan if :dmp_id was not present" do
        @json[:dmp_id] = []
        result = described_class.send(:marshal_plan, json: @json)
        expect(result.new_record?).to eql(true)
        expect(result.template_id).to eql(@template.id)
      end
      it "creates a new Plan if :dmp_id was not found" do
        @json[:dmp_id][:identifier] = SecureRandom.uuid
        result = described_class.send(:marshal_plan, json: @json)
        expect(result.new_record?).to eql(true)
        expect(result.template_id).to eql(@template.id)
      end
    end

    describe "#deserialize_project(plan:, json:)" do
      before(:each) do
        # clear out the dates set in the factory
        @plan.start_date = nil
        @plan.end_date = nil
      end

      it "returns the Plan as-is if the json is not present" do
        result = described_class.send(:deserialize_project, plan: @plan, json: nil)
        expect(result).to eql(@plan)
        expect(result.start_date).to eql(nil)
      end
      it "returns the Plan as-is if the json :project is not present" do
        json = { title: Faker::Lorem.sentence }
        result = described_class.send(:deserialize_project, plan: @plan, json: json)
        expect(result).to eql(@plan)
        expect(result.start_date).to eql(nil)
      end
      it "returns the Plan as-is if the json :project is not an array" do
        json = {
          title: Faker::Lorem.sentence,
          project: { start: Time.now.to_formatted_s(:iso8601) }
        }
        result = described_class.send(:deserialize_project, plan: @plan, json: json)
        expect(result).to eql(@plan)
        expect(result.start_date).to eql(nil)
      end
      it "assigns the start_date of the Plan" do
        result = described_class.send(:deserialize_project, plan: @plan, json: @json)
        expected = Time.new(@json[:project].first[:start]).utc.to_formatted_s(:iso8601)
        expect(result.start_date.to_formatted_s(:iso8601)).to eql(expected)
      end
      it "assigns the end_date of the Plan" do
        result = described_class.send(:deserialize_project, plan: @plan, json: @json)
        expected = Time.new(@json[:project].first[:end]).utc.to_formatted_s(:iso8601)
        expect(result.end_date.to_formatted_s(:iso8601)).to eql(expected)
      end
      it "does not call the deserializer for Funding if :funding is not present" do
        @json[:project].first[:funding] = nil
        Api::V1::Deserialization::Funding.expects(:deserialize!).at_most(0)
        described_class.send(:deserialize_project, plan: @plan, json: @json)
      end
      it "calls the deserializer for Funding if :funding present" do
        Api::V1::Deserialization::Funding.expects(:deserialize!).at_least(1)
        described_class.send(:deserialize_project, plan: @plan, json: @json)
      end
    end

    describe "#deserialize_contact(plan:, json:)" do
      it "returns the Plan as-is if json is not present" do
        result = described_class.send(:deserialize_contact, plan: @plan, json: nil)
        expect(result).to eql(@plan)
        expect(result.contributors.length).to eql(0)
      end
      it "returns the Plan as-is if json :contact is not present" do
        @json[:contact] = nil
        result = described_class.send(:deserialize_contact, plan: @plan, json: @json)
        expect(result).to eql(@plan)
        expect(result.contributors.length).to eql(0)
      end
      it "calls the Contributor.deserialize! for the contact entry" do
        Api::V1::Deserialization::Contributor.expects(:deserialize!).at_least(1)
        described_class.send(:deserialize_contact, plan: @plan, json: @json)
      end
      it "attaches the Contributors to the Plan" do
        result = described_class.send(:deserialize_contact, plan: @plan, json: @json)
        expect(result.contributors.length).to eql(1)
        expect(result.contributors.first.name).to eql(@json[:contact][:name])
      end
    end

    describe "#deserialize_contributors(plan:, json:)" do
      it "calls the Contributor.deserialize! for each contributor entry" do
        Api::V1::Deserialization::Contributor.expects(:deserialize!).at_least(2)
        described_class.send(:deserialize_contributors, plan: @plan, json: @json)
      end
      it "attaches the Contributors to the Plan" do
        result = described_class.send(:deserialize_contributors, plan: @plan,
                                                                 json: @json)
        expect(result.contributors.length).to eql(2)
        expect(result.contributors.first.name).to eql(@json[:contributor].first[:name])
        expect(result.contributors.last.name).to eql(@json[:contributor].last[:name])
      end
    end

    describe "#find_by_identifier(json:)" do
      it "returns nil if json is not present" do
        expect(described_class.send(:find_by_identifier, json: nil)).to eql(nil)
      end
      it "returns nil if json has no :dmp_id" do
        json = { contact_id: { type: "url", identifier: SecureRandom.uuid } }
        expect(described_class.send(:find_by_identifier, json: json)).to eql(nil)
      end
      it "calls Plan.from_identifiers if the :dmp_id is a DOI/ARK" do
        described_class.stubs(:doi?).returns(true)
        Plan.expects(:from_identifiers).at_least(1)
        described_class.send(:find_by_identifier, json: @json)
      end
      it "calls Plan.find_by if the :dmp_id is not a DOI/ARK" do
        described_class.stubs(:doi?).returns(false)
        Plan.expects(:find_by).at_least(1)
        described_class.send(:find_by_identifier, json: @json)
      end
    end

    describe "doi?(value:)" do
      it "returns false if value is not present" do
        expect(described_class.send(:doi?, value: nil)).to eql(false)
      end
      it "returns false if the value does not match ARK or DOI pattern" do
        url = Faker::Internet.url
        expect(described_class.send(:doi?, value: url)).to eql(false)
      end
      it "returns false if the value does not match a partial ARK/DOI pattern" do
        val = "23645gy3d"
        expect(described_class.send(:doi?, value: val)).to eql(false)
        val = "10.999"
        expect(described_class.send(:doi?, value: val)).to eql(false)
      end
      it "returns false if there is no 'doi' identifier scheme" do
        val = "10.999/23645gy3d"
        @scheme.destroy
        expect(described_class.send(:doi?, value: val)).to eql(false)
      end
      it "returns false if 'doi' identifier scheme exists but value is not doi" do
        expect(described_class.send(:doi?, value: SecureRandom.uuid)).to eql(false)
      end
      it "returns true (identifier only)" do
        val = "10.999/23645gy3d"
        expect(described_class.send(:doi?, value: val)).to eql(true)
      end
      it "returns true (fully qualified ARK/DOI url)" do
        url = "#{Faker::Internet.url}/10.999/23645gy3d"
        expect(described_class.send(:doi?, value: url)).to eql(true)
      end
    end

    describe "#find_template(json:)" do
      it "returns nil if the json is not present" do
        expect(described_class.send(:find_template, json: nil)).to eql(nil)
      end
      it "returns default template if no template is found for the :id" do
        json = { template: { id: 9999, title: Faker::Lorem.sentence } }
        expect(described_class.send(:find_template, json: json)).to eql(nil)
      end
      it "returns the specified template" do
        expect(described_class.send(:find_template, json: @json)).to eql(@template)
      end
    end

    describe "template_id(json:)" do
      it "returns nil if json not present" do
        expect(described_class.send(:template_id, json: nil)).to eql(nil)
      end
      it "returns nil if extensions for the app were not found" do
        described_class.stubs(:app_extensions).returns({})
        expect(described_class.send(:template_id, json: @json)).to eql(nil)
      end
      it "returns nil if the extensions have no template info" do
        expected = { foo: { title: Faker::Lorem.sentence } }
        described_class.stubs(:app_extensions).returns(expected)
        expect(described_class.send(:template_id, json: @json)).to eql(nil)
      end
      it "returns nil if the extensions have no id for the template info" do
        expected = { template: { title: Faker::Lorem.sentence } }
        described_class.stubs(:app_extensions).returns(expected)
        expect(described_class.send(:template_id, json: @json)).to eql(nil)
      end
      it "returns the template id" do
        expect(described_class.send(:template_id, json: @json)).to eql(@template.id)
      end
    end

    describe "#app_extensions(json:)" do
      it "returns an empty hash is json is not present" do
        expect(described_class.send(:app_extensions, json: nil)).to eql({})
      end
      it "returns an empty hash is json :extended_attributes is not present" do
        json = { title: Faker::Lorem.sentence }
        expect(described_class.send(:app_extensions, json: json)).to eql({})
      end
      it "returns an empty hash if there is no extension for the current application" do
        expected = { template: { id: @template.id } }
        ApplicationService.expects(:application_name).returns("tester")
        json = { extension: [{ foo: expected }] }
        expect(described_class.send(:app_extensions, json: json)).to eql({})
      end
      it "returns the hash for the current application" do
        expected = { template: { id: @template.id } }
        json = { extension: [{ "#{@app_name}": expected }] }
        result = described_class.send(:app_extensions, json: json)
        expect(result).to eql(expected)
      end
    end

  end

end
