# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalApis::DataciteService, type: :model do
  include DataciteMocks

  before(:each) do
    unless Language.where(default_language: true).any?
      # Org model requires a language so make sure the default is set
      create(:language, default_language: true)
    end
    @plan = create(:plan, :creator)
    create(:contributor, investigation: true, plan: @plan)
    create(:identifier, identifiable: @plan)
    @plan.reload
  end

  describe "#mint_doi" do
    before(:each) do
      stub_minting_error!
    end

    it "returns the new DOI" do
      stub_minting_success!
      doi = described_class.mint_doi(plan: @plan)
      expect(doi).to eql("10.99999/abc123-566")
    end

    it "returns nil if Datacite returned an error" do
      doi = described_class.mint_doi(plan: @plan)
      expect(doi).to eql(nil)
    end
  end

  context "private methods" do
    describe "#auth" do
      before(:each) do
        @hash = described_class.send(:auth)
      end

      it "returns the correct username" do
        expect(@hash.include?(:username)).to eql(true)
        expect(@hash[:username]).to eql(Rails.configuration.x.datacite&.repository_id)
      end

      it "returns the correct password" do
        expect(@hash.include?(:password)).to eql(true)
        expect(@hash[:password]).to eql(Rails.configuration.x.datacite&.password)
      end
    end

    # rubocop:disable Layout/LineLength
    describe "#json_from_template(dmp:)" do
      it "properly generates the JSON for submission to DataCite" do
        orcid = create(:identifier_scheme, name: "orcid")
        ror = create(:identifier_scheme, name: "ror")
        creator_orcid = create(:identifier, identifiable: @plan.owner,
                                            identifier_scheme: orcid)
        contrib = @plan.contributors.reject { |c| c == @plan.owner }.first
        contrib_orcid = create(:identifier, identifiable: contrib,
                                            identifier_scheme: orcid)
        creator_ror = create(:identifier, identifiable: @plan.owner.org,
                                          identifier_scheme: ror)
        contributor_ror = create(:identifier, identifiable: contrib.org,
                                              identifier_scheme: ror)

        json = JSON.parse(described_class.send(:json_from_template, dmp: @plan))

        expect(json["data"].present?).to eql(true)
        expect(json["data"]["type"]).to eql("dois")
        expect(json["data"]["attributes"].present?).to eql(true)

        # DMP checks
        dmp_json = json["data"]["attributes"]
        expect(dmp_json["prefix"]).to eql(described_class.shoulder)
        expect(dmp_json["schemaVersion"]).to eql("http://datacite.org/schema/kernel-4")
        expect(dmp_json["titles"].first["title"]).to eql(@plan.title)
        expect(dmp_json["descriptions"].first["description"]).to eql(@plan.description)
        expect(dmp_json["descriptions"].first["descriptionType"]).to eql("Abstract")
        expect(dmp_json["publisher"]).to eql(ApplicationService.application_name)
        expect(dmp_json["publicationYear"]).to eql(Time.now.year)
        expect(dmp_json["dates"].length).to eql(2)
        expect(dmp_json["dates"].first["dateType"]).to eql("Created")
        expect(dmp_json["dates"].first["date"]).to eql(@plan.created_at.to_formatted_s(:iso8601))
        expect(dmp_json["dates"].last["dateType"]).to eql("Updated")
        expect(dmp_json["dates"].last["date"]).to eql(@plan.created_at.to_formatted_s(:iso8601))

        # Related Identifiers checks
        expected = Rails.application.routes.url_helpers.api_v1_plan_url(@plan)
        expect(dmp_json["relatedIdentifiers"].first.present?).to eql(true)
        expect(dmp_json["relatedIdentifiers"].first["relatedIdentifier"]).to eql(expected)
        expect(dmp_json["relatedIdentifiers"].first["relatedIdentifierType"]).to eql("IsMetadataFor")

        # Type checks
        type = dmp_json["types"]
        expect(type["resourceType"]).to eql("Text/DataManagementPlan")
        expect(type["resourceTypeGeneral"]).to eql("Text")

        # Creators check
        creator = dmp_json["creators"].first
        expected = @plan.owner.reload
        expect(creator["name"]).to eql([expected.surname, expected.firstname].join(", "))
        expect(creator["nameType"]).to eql("Personal")
        expect(creator["nameIdentifiers"].first["schemeUri"]).to eql("https://orcid.org")
        expect(creator["nameIdentifiers"].first["nameIdentifierScheme"]).to eql("ORCID")
        expect(creator["nameIdentifiers"].first["nameIdentifier"].end_with?(creator_orcid.value)).to eql(true)
        expect(creator["affiliation"].present?).to eql(true)
        expect(creator["affiliation"]["name"]).to eql(expected.org.name)
        expect(creator["affiliation"]["affiliationIdentifierScheme"]).to eql("ROR")
        expect(creator["affiliation"]["affiliationIdentifier"]).to eql(creator_ror.value)

        # Contributors check
        contrib = dmp_json["contributors"].first
        expected = @plan.contributors.last.reload
        expect(contrib["name"]).to eql(expected.name)
        expect(contrib["nameType"]).to eql("Personal")
        expect(contrib["contributorType"]).to eql("ProjectLeader")
        expect(contrib["nameIdentifiers"].first["schemeUri"]).to eql("https://orcid.org")
        expect(contrib["nameIdentifiers"].first["nameIdentifierScheme"]).to eql("ORCID")
        expect(contrib["nameIdentifiers"].first["nameIdentifier"].end_with?(contrib_orcid.value)).to eql(true)
        expect(contrib["affiliation"].present?).to eql(true)
        expect(contrib["affiliation"]["name"]).to eql(expected.org.name)
        expect(contrib["affiliation"]["affiliationIdentifierScheme"]).to eql("ROR")
        expect(contrib["affiliation"]["affiliationIdentifier"]).to eql(contributor_ror.value)
      end
    end

    describe "#process_response(response:)" do
      it "returns nil if JSON for Datacite does not have ['data']" do
        resp = OpenStruct.new(body: { "foo": "bar" }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns nil if JSON for Datacite does not have ['data']['attributes']" do
        resp = OpenStruct.new(body: { "data": { "type": "dois" } }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns nil if JSON for Datacite does not have ['data']['attributes']['relatedIdentifiers']" do
        resp = OpenStruct.new(body: { "data": { "attributes": { "types": [] } } }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns nil if JSON is unparseable" do
        resp = OpenStruct.new(body: Faker::Lorem.sentence)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns the response as JSON" do
        expected = { "data": { "attributes": { "doi": ["foo"] } } }
        resp = OpenStruct.new(body: expected.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(JSON.parse(expected.to_json))
      end
    end
    # rubocop:enable Layout/LineLength

  end

end
