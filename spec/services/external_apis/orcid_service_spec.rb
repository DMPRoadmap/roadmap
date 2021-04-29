# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalApis::OrcidService, type: :model do

  include IdentifierHelper
  include Webmocks

  before(:each) do
    Rails.configuration.x.allow_doi_minting = true
    Rails.configuration.x.orcid.active = true

    scheme = orcid_scheme
    @plan = create(:plan, :creator)
    co_owner = create(:user)
    create(:role, :administrator, user: co_owner, plan: @plan)
    create_doi(plan: @plan)
    create_orcid(user: @plan.owner)
    create(:external_api_access_token, user: @plan.owner, external_service_name: scheme.name.downcase)
    @plan.reload

    stub_orcid
  end

  describe "#add_work(user:, plan:)" do
    it "returns false if the user is not a User" do
      expect(described_class.add_work(user: build(:org), plan: @plan)).to eql(false)
    end
    it "returns false if the plan is not a Plan" do
      expect(described_class.add_work(user: @plan.owner, plan: build(:department))).to eql(false)
    end
    it "returns false if the plan has no DMP ID (aka DOI)" do
      @plan.identifiers.clear
      expect(described_class.add_work(user: nil, plan: @plan)).to eql(false)
    end
    it "returns false if there is no IdentifierScheme defined for ORCID" do
      @scheme.destroy
      expect(described_class.add_work(user: nil, plan: @plan)).to eql(false)
    end
    it "returns false if the User has no access token for ORCID" do
      @plan.owner.external_api_access_tokens.clear
      expect(described_class.add_work(user: nil, plan: @plan)).to eql(false)
    end
    it "adds the DMP to the ORCID record as a work" do
      result = described_class.add_work(user: @plan.owner, plan: @plan)
      expect(result).to eql("10.99999/abc123-566")
    end
  end

=begin
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
        expect(dmp_json["dates"].last["date"]).to eql(@plan.updated_at.to_formatted_s(:iso8601))

        # Related Identifiers checks
        expected = Rails.application.routes.url_helpers.api_v1_plan_url(@plan)
        expect(dmp_json["relatedIdentifiers"].first.present?).to eql(true)
        expect(dmp_json["relatedIdentifiers"].first["relatedIdentifier"]).to eql(expected)
        expect(dmp_json["relatedIdentifiers"].first["relatedIdentifierType"]).to eql("IsMetadataFor")

        # Type checks
        type = dmp_json["types"]
        expect(type["resourceType"]).to eql("Text/Data Management Plan")
        expect(type["resourceTypeGeneral"]).to eql("Text")

        # Creators check
        creator = dmp_json["creators"].first
        expected = @plan.owner.reload
        expect(creator["name"]).to eql([expected.surname, expected.firstname].join(", "))
        expect(creator["nameType"]).to eql("Personal")
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
=end

end
