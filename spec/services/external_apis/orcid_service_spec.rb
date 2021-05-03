# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalApis::OrcidService, type: :model do

  include IdentifierHelper
  include Webmocks

  before(:each) do
    Rails.configuration.x.allow_doi_minting = true
    Rails.configuration.x.orcid.active = true
    Rails.configuration.x.orcid.api_base_url = Faker::Internet.url
    Rails.configuration.x.orcid.callback_path = "/#{Faker::Lorem.word}/%{put_code}"

    @scheme = orcid_scheme
    @plan = create(:plan, :creator)
    create_doi(plan: @plan)
    create_orcid(user: @plan.owner)

    co_owner = create(:user)
    create_orcid(user: co_owner)
    create(:role, :administrator, user: co_owner, plan: @plan)

    create(:external_api_access_token, user: @plan.owner, external_service_name: @scheme.name.downcase)
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
      expect(result.present?).to eql(true)
    end
  end

  describe "#add_subscription(plan:, put_code:)" do
    it "returns nil if :plan is not a Plan" do
      expect(described_class.add_subscription(plan: nil, put_code: Faker::Lorem.word)).to eql(nil)
    end
    it "returns nil if :put_code is not present" do
      expect(described_class.add_subscription(plan: @plan, put_code: nil)).to eql(nil)
      expect(@plan.reload.subscriptions.any?).to eql(false)
    end
    it "returns nil if there is no IdentifierScheme for ORCID" do
      @scheme.destroy
      expect(described_class.add_subscription(plan: @plan, put_code: Faker::Lorem.word)).to eql(nil)
    end
    it "returns nil if no callback_path is defined in the config" do
      Rails.configuration.x.orcid.callback_path = nil
      expect(described_class.add_subscription(plan: @plan, put_code: Faker::Lorem.word)).to eql(nil)
      expect(@plan.reload.subscriptions.any?).to eql(false)
    end
    it "adds the subscription for the ORCID IdentifierScheme" do
      code = Faker::Lorem.word
      result = described_class.add_subscription(plan: @plan, put_code: code)
      expect(@plan.reload.subscriptions.any?).to eql(true)
      expect(result.is_a?(Subscription)).to eql(true)
      expect(result.plan_id).to eql(@plan.id)
      expect(result.subscriber_id).to eql(@scheme.id)
      expect(result.subscriber_type).to eql(@scheme.class.name)
      expected = "#{described_class.api_base_url}#{described_class.callback_path % { put_code: code }}"
      expect(result.callback_uri).to eql(expected)
    end
  end

  describe "#update_subscription(plan:)" do
    it "returns false if :plan is not a Plan" do
      expect(described_class.update_subscription(plan: build(:org))).to eql(false)
    end
    it "returns false if there is no IdentifierScheme for ORCID" do
      @scheme.destroy
      expect(described_class.update_subscription(plan: @plan)).to eql(false)
    end
    it "returns nil if the :plan has no subscriptions" do
      expect(described_class.update_subscription(plan: @plan)).to eql(false)
    end
    it "returns true if successful" do
      described_class.expects(:identifier_scheme).returns(@scheme).twice
      subscription = create(:subscription, plan: @plan, subscriber: @scheme)
      expect(described_class.update_subscription(plan: @plan)).to eql(true)
    end
  end

  context "private methods" do
    describe "#identifier_scheme" do
      it "returns nil if there is no identifier_scheme record defined" do
        @scheme.destroy
        expect(described_class.send(:identifier_scheme)).to eql(nil)
      end
      it "returns the identifier_scheme that matches the :name" do
        expect(described_class.send(:identifier_scheme)).to eql(@scheme)
      end
    end

    describe "#xml_for(plan:, doi:)" do
      it "returns nil if :plan is not a Plan" do
        expect(described_class.send(:xml_for, plan: nil, doi: @plan.doi)).to eql(nil)
      end
      it "returns nil if :doi is not an Identifier" do
        expect(described_class.send(:xml_for, plan: @plan, doi: nil)).to eql(nil)
      end
      it "returns the expected XML" do
        xml = Nokogiri::XML(described_class.send(:xml_for, plan: @plan, doi: @plan.doi))
        expect(xml.xpath("//common:title").text).to eql(@plan.title)
        expect(xml.xpath("//work:short-description").text).to eql(@plan.description)
        expect(xml.xpath("//work:citation-value").text).to eql(@plan.citation)
        expect(xml.xpath("//common:year").text).to eql(@plan.created_at.strftime("%Y"))
        expect(xml.xpath("//common:month").text).to eql(@plan.created_at.strftime("%m"))
        expect(xml.xpath("//common:day").text).to eql(@plan.created_at.strftime("%d"))
        expect(xml.xpath("//common:external-id-value").text).to eql(@plan.doi.value_without_scheme_prefix)
        expect(xml.xpath("//common:external-id-url").text).to eql(@plan.doi.value)
        expect(xml.xpath("//work:contributor").length).to eql(2)
      end
    end

    describe "#contributors_as_xml(authors:)" do
      it "returns an empty string unless there are :authors" do
        expect(described_class.send(:contributors_as_xml, authors: nil)).to eql("")
        expect(described_class.send(:contributors_as_xml, authors: [])).to eql("")
      end
      it "returns the expected XML" do
        authors = @plan.owner_and_coowners
        xml = described_class.send(:contributors_as_xml, authors: authors)
        authors.each do |author|
          orcid = author.identifier_for_scheme(scheme: "orcid")
          expect(xml.include?("<common:uri>#{orcid.value}</common:uri>")).to eql(true)
          expect(xml.include?("<common:path>#{orcid.value_without_scheme_prefix}</common:path>")).to eql(true)
          expect(xml.include?("<work:credit-name>#{author.name(false)}</work:credit-name>")).to eql(true)
        end
      end
    end
  end

end
