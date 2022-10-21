# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::OrcidService, type: :model do
  include Helpers::IdentifierHelper
  include Helpers::Webmocks

  before(:each) do
    Rails.configuration.x.allow_dmp_id_minting = true
    Rails.configuration.x.orcid.active = true
    Rails.configuration.x.orcid.api_base_url = 'https://api.sandbox.orcid.org/v3.0/'
    Rails.configuration.x.orcid.landing_page_url = Faker::Internet.url
    Rails.configuration.x.orcid.callback_path = "/#{Faker::Lorem.word}/%{put_code}"
    Rails.configuration.x.orcid.work_path = "/%{id}/#{Faker::Lorem.word}"

    @scheme = orcid_scheme
    @plan = create(:plan, :creator)
    create_dmp_id(plan: @plan)
    create_orcid(user: @plan.owner)

    co_owner = create(:user)
    create_orcid(user: co_owner)
    create(:role, :administrator, user: co_owner, plan: @plan)

    create(:external_api_access_token, user: @plan.owner, external_service_name: @scheme.name.downcase)
    @plan.reload

    stub_orcid
  end

  describe '#add_work(user:, plan:)' do
    it 'returns false if the user is not a User' do
      expect(described_class.add_work(user: build(:org), plan: @plan)).to eql(false)
    end
    it 'returns false if the plan is not a Plan' do
      expect(described_class.add_work(user: @plan.owner, plan: build(:department))).to eql(false)
    end
    it 'returns false if the plan has no DMP ID (aka DOI)' do
      @plan.identifiers.clear
      expect(described_class.add_work(user: nil, plan: @plan)).to eql(false)
    end
    it 'returns false if there is no IdentifierScheme defined for ORCID' do
      @scheme.destroy
      expect(described_class.add_work(user: nil, plan: @plan)).to eql(false)
    end
    it 'returns false if the User has no access token for ORCID' do
      @plan.owner.external_api_access_tokens.clear
      expect(described_class.add_work(user: nil, plan: @plan)).to eql(false)
    end
    it 'adds the DMP to the ORCID record as a work' do
      result = described_class.add_work(user: @plan.owner, plan: @plan)
      expect(result.present?).to eql(true)
    end
  end

  describe '#add_subscription(plan:, callback_uri:)' do
    it 'returns nil if :plan is not a Plan' do
      expect(described_class.add_subscription(plan: nil, callback_uri: Faker::Internet.url)).to eql(nil)
    end
    it 'returns nil if :put_code is not present' do
      expect(described_class.add_subscription(plan: @plan, callback_uri: nil)).to eql(nil)
      expect(@plan.reload.subscriptions.any?).to eql(false)
    end
    it 'returns nil if there is no IdentifierScheme for ORCID' do
      @scheme.destroy
      expect(described_class.add_subscription(plan: @plan, callback_uri: Faker::Internet.url)).to eql(nil)
    end
    it 'adds the subscription for the ORCID IdentifierScheme' do
      uri = Faker::Internet.url
      result = described_class.add_subscription(plan: @plan, callback_uri: uri)
      expect(@plan.reload.subscriptions.any?).to eql(true)
      expect(result.is_a?(Subscription)).to eql(true)
      expect(result.plan_id).to eql(@plan.id)
      expect(result.subscriber_id).to eql(@scheme.id)
      expect(result.subscriber_type).to eql(@scheme.class.name)
      expect(result.callback_uri).to eql(uri)
    end
  end

  describe '#update_subscription(plan:)' do
    it 'returns false if :plan is not a Plan' do
      expect(described_class.update_subscription(plan: build(:org))).to eql(false)
    end
    it 'returns false if there is no IdentifierScheme for ORCID' do
      @scheme.destroy
      expect(described_class.update_subscription(plan: @plan)).to eql(false)
    end
    it 'returns nil if the :plan has no subscriptions' do
      expect(described_class.update_subscription(plan: @plan)).to eql(false)
    end
    it 'returns true if successful' do
      described_class.expects(:identifier_scheme).returns(@scheme).twice
      create(:subscription, plan: @plan, subscriber: @scheme)
      expect(described_class.update_subscription(plan: @plan)).to eql(true)
    end
  end

  context 'private methods' do
    describe '#identifier_scheme' do
      it 'returns nil if there is no identifier_scheme record defined' do
        @scheme.destroy
        expect(described_class.send(:identifier_scheme)).to eql(nil)
      end
      it 'returns the identifier_scheme that matches the :name' do
        expect(described_class.send(:identifier_scheme)).to eql(@scheme)
      end
    end

    describe '#xml_for(plan:, dmp_id:, user:)' do
      it 'returns nil if :plan is not a Plan' do
        expect(described_class.send(:xml_for, plan: nil, dmp_id: @plan.dmp_id, user: @plan.owner)).to eql(nil)
      end
      it 'returns nil if :dmp_id is not an Identifier' do
        expect(described_class.send(:xml_for, plan: @plan, dmp_id: nil, user: @plan.owner)).to eql(nil)
      end
      it 'returns nil if :user is not an User' do
        expect(described_class.send(:xml_for, plan: @plan, dmp_id: @plan.dmp_id, user: nil)).to eql(nil)
      end
      it 'returns the expected XML' do
        xml = Nokogiri::XML(described_class.send(:xml_for, plan: @plan, dmp_id: @plan.dmp_id, user: @plan.owner))
        expect(xml.xpath('//common:title').text).to eql(@plan.title)
        expect(xml.xpath('//work:short-description').text).to eql(@plan.description)
        expect(xml.xpath('//work:citation-value').text).to eql(@plan.citation)
        expect(xml.xpath('//common:year').text).to eql(@plan.created_at.strftime('%Y'))
        expect(xml.xpath('//common:month').text).to eql(@plan.created_at.strftime('%m'))
        expect(xml.xpath('//common:day').text).to eql(@plan.created_at.strftime('%d'))
        expect(xml.xpath('//common:external-id-value').text).to eql(@plan.dmp_id.value_without_scheme_prefix)
        expect(xml.xpath('//common:external-id-url').text).to eql(@plan.dmp_id.value)
      end
      it 'handles invalid XML characters in :title, :description, and :citation properly' do
        @plan.title = 'Foo</work:citation-value>'
        @plan.description = 'Foo Bar \\n Baz <Foo>'

        xml = Nokogiri::XML(described_class.send(:xml_for, plan: @plan, dmp_id: @plan.dmp_id, user: @plan.owner))
        expect(xml.xpath('//common:title').text).to eql('Foo</work:citation-value>')
        expect(xml.xpath('//work:short-description').text).to eql('Foo Bar \\n Baz <Foo>')
        expect(xml.xpath('//work:citation-value').text).to eql(@plan.citation)
        expect(xml.xpath('//common:year').text).to eql(@plan.created_at.strftime('%Y'))
        expect(xml.xpath('//common:month').text).to eql(@plan.created_at.strftime('%m'))
        expect(xml.xpath('//common:day').text).to eql(@plan.created_at.strftime('%d'))
        expect(xml.xpath('//common:external-id-value').text).to eql(@plan.dmp_id.value_without_scheme_prefix)
        expect(xml.xpath('//common:external-id-url').text).to eql(@plan.dmp_id.value)
      end
    end
  end
end
