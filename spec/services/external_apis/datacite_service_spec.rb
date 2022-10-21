# frozen_string_literal: true

require 'rails_helper'

# TODO: Skipping certain tests here because the service calls 'render_to_string' outside of 
#       the request response context and is failing in Rails 6+ when that method attempts
#       to access Request.headers
RSpec.describe ExternalApis::DataciteService, type: :model do
  include Mocks::DataciteMocks
  include Helpers::IdentifierHelper

  before(:each) do
    Rails.configuration.x.madmp.enable_dmp_id_registration = true
    Rails.configuration.x.datacite.active = true
    Rails.configuration.x.datacite.api_base_url = 'https://api.test.datacite.org/'

    unless Language.where(default_language: true).any?
      # Org model requires a language so make sure the default is set
      create(:language, default_language: true)
    end
    @plan = create(:plan, :creator)
    create(:contributor, investigation: true, plan: @plan)
    create_dmp_id(plan: @plan)
    @client = create(:api_client)
    @plan.reload
    @dmp_id = @plan.dmp_id.value_without_scheme_prefix
  end

  describe '#mint_dmp_id' do
    it 'returns nil if the service is not active' do
      Rails.configuration.x.datacite.active = false
      stub_minting_success!
      dmp_id = described_class.mint_dmp_id(plan: @plan)
      expect(dmp_id).to eql(nil)
    end
    xit 'handles the http failure and notifies admins if HTTP response is not 200' do
      stub_minting_error!
      described_class.expects(:handle_http_failure).returns(true)
      described_class.expects(:notify_administrators).returns(true)
      result = described_class.mint_dmp_id(plan: @plan)
      expect(result).to eql(nil)
    end
    xit 'returns the new DMP ID' do
      stub_minting_success!
      dmp_id = described_class.mint_dmp_id(plan: @plan)
      expect(dmp_id).to eql('10.99999/abc123-566')
    end
  end

  describe '#update_dmp_id(plan:)' do
    it 'returns false if the DataciteService is not active' do
      Rails.configuration.x.datacite.active = false
      expect(described_class.update_dmp_id(plan: @plan)).to eql(false)
    end
    it 'returns false if :plan is not present' do
      expect(described_class.update_dmp_id(plan: nil)).to eql(false)
    end
    xit 'handles the http failure and notifies admins if HTTP response is not 200' do
      stub_update_error!
      described_class.expects(:handle_http_failure).returns(true)
      described_class.expects(:notify_administrators).returns(true)
      result = described_class.update_dmp_id(plan: @plan)
      expect(result).to eql(false)
    end
    xit 'processes the response, updates the subscription and returns true' do
      stub_update_success!
      described_class.expects(:update_subscription).returns(true)
      result = described_class.update_dmp_id(plan: @plan)
      expect(result).to eql(true)
    end
  end

  describe '#delete_dmp_id(plan:)' do
    xit 'should be tested when it is implemented!' do
      # TODO: Once this method has been defined we need to test it
    end
  end

  describe '#add_subscription(plan:, dmp_id:)' do
    it 'returns nil if the :plan is not present' do
      result = described_class.add_subscription(plan: nil, dmp_id: @dmp_id)
      expect(result).to eql(nil)
    end
    it 'returns nil if the :dmp_id is not present' do
      result = described_class.add_subscription(plan: @plan, dmp_id: nil)
      expect(result).to eql(nil)
    end
    it 'logs a warning and returns nil if no ApiClient is defined' do
      described_class.expects(:api_client).returns(nil)
      described_class.expects(:callback_path).returns(nil)
      Rails.logger.expects(:warn)
      result = described_class.add_subscription(plan: @plan, dmp_id: @dmp_id)
      expect(result).to eql(nil)
    end
    it 'returns nil if the :callback_path is not present' do
      described_class.expects(:api_client).returns(@client)
      described_class.expects(:callback_path).returns(nil)
      result = described_class.add_subscription(plan: @plan, dmp_id: @dmp_id)
      expect(result).to eql(nil)
    end
    it 'creates a new Subscription' do
      described_class.expects(:api_client).returns(@client)
      described_class.expects(:callback_path).returns('https://doi.org/123.123/%{dmp_id}')
      result = described_class.add_subscription(plan: @plan, dmp_id: @dmp_id)
      expect(result.plan).to eql(@plan)
      expect(result.subscriber).to eql(@client)
      expect(result.callback_uri).to eql("https://doi.org/123.123/#{@dmp_id}")
      expect(result.creations?).to eql(false)
      expect(result.updates?).to eql(true)
      expect(result.deletions?).to eql(true)
    end
  end

  describe '#update_subscription(plan:)' do
    it 'returns false if the :plan is not present' do
      result = described_class.update_subscription(plan: nil)
      expect(result).to eql(false)
    end
    it 'returns false if the :dmp_id is not present' do
      @plan.identifiers.clear
      result = described_class.update_subscription(plan: @plan)
      expect(result).to eql(false)
    end
    it 'logs a warning and returns nil if no ApiClient is defined' do
      described_class.expects(:api_client).returns(nil)
      described_class.expects(:callback_path).returns(nil)
      Rails.logger.expects(:warn)
      result = described_class.update_subscription(plan: @plan)
      expect(result).to eql(false)
    end
    it 'returns false if the :callback_path is not present' do
      described_class.expects(:api_client).returns(@client)
      described_class.expects(:callback_path).returns(nil)
      result = described_class.update_subscription(plan: @plan)
      expect(result).to eql(false)
    end
    it 'returns false if there is no subscription for the plan+api_client' do
      described_class.expects(:api_client).returns(@client)
      described_class.expects(:callback_path).returns(Faker::Internet.unique.url)
      create(:subscription, :for_updates, plan: @plan, subscriber: create(:api_client),
                                          last_notified: Time.now - 2.hours)
      result = described_class.update_subscription(plan: @plan)
      expect(result).to eql(false)
    end
    it 'returns true' do
      described_class.expects(:api_client).returns(@client)
      described_class.expects(:callback_path).returns(Faker::Internet.unique.url)
      orig = Time.now - 2.hours
      @plan.subscriptions << create(:subscription, :for_updates, plan: @plan,
                                                                 subscriber: @client,
                                                                 last_notified: orig,
                                                                 updates: true)
      result = described_class.update_subscription(plan: @plan)
      expect(result).to eql(true)
      expect(@plan.reload.subscriptions.first.last_notified > orig)
    end
  end

  context 'private methods' do
    describe '#auth' do
      before(:each) do
        @hash = described_class.send(:auth)
      end

      it 'returns the correct username' do
        expect(@hash.include?(:username)).to eql(true)
        expect(@hash[:username]).to eql(Rails.configuration.x.datacite&.repository_id)
      end

      it 'returns the correct password' do
        expect(@hash.include?(:password)).to eql(true)
        expect(@hash[:password]).to eql(Rails.configuration.x.datacite&.password)
      end
    end

    describe '#json_from_template(dmp:)' do
      xit 'properly generates the JSON for submission to DataCite' do
        orcid = create(:identifier_scheme, name: 'orcid')
        ror = create(:identifier_scheme, name: 'ror')
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

        expect(json['data'].present?).to eql(true)
        expect(json['data']['type']).to eql('dois')
        expect(json['data']['attributes'].present?).to eql(true)

        # DMP checks
        dmp_json = json['data']['attributes']
        expect(dmp_json['prefix']).to eql(described_class.shoulder)
        expect(dmp_json['schemaVersion']).to eql('http://datacite.org/schema/kernel-4')
        expect(dmp_json['titles'].first['title']).to eql(@plan.title)
        expect(dmp_json['descriptions'].first['description']).to eql(@plan.description)
        expect(dmp_json['descriptions'].first['descriptionType']).to eql('Abstract')
        expect(dmp_json['publisher']).to eql(ApplicationService.application_name)
        expect(dmp_json['publicationYear']).to eql(Time.now.year)
        expect(dmp_json['dates'].length).to eql(2)
        expect(dmp_json['dates'].first['dateType']).to eql('Created')
        expect(dmp_json['dates'].first['date']).to eql(@plan.created_at.to_formatted_s(:iso8601))
        expect(dmp_json['dates'].last['dateType']).to eql('Updated')
        expect(dmp_json['dates'].last['date']).to eql(@plan.updated_at.to_formatted_s(:iso8601))

        # Related Identifiers checks
        expected = Rails.application.routes.url_helpers.api_v1_plan_url(@plan)
        expect(dmp_json['relatedIdentifiers'].first.present?).to eql(true)
        expect(dmp_json['relatedIdentifiers'].first['relatedIdentifier']).to eql(expected)
        expect(dmp_json['relatedIdentifiers'].first['relatedIdentifierType']).to eql('IsMetadataFor')

        # Type checks
        type = dmp_json['types']
        expect(type['resourceType']).to eql('Data Management Plan')
        expect(type['resourceTypeGeneral']).to eql('OutputManagementPlan')

        # Creators check
        creator = dmp_json['creators'].first
        expected = @plan.owner.reload
        expect(creator['name']).to eql([expected.surname, expected.firstname].join(', '))
        expect(creator['nameType']).to eql('Personal')
        expect(creator['nameIdentifiers'].first['nameIdentifierScheme']).to eql('ORCID')
        expect(creator['nameIdentifiers'].first['nameIdentifier'].end_with?(creator_orcid.value)).to eql(true)
        expect(creator['affiliation'].present?).to eql(true)
        expect(creator['affiliation']['name']).to eql(expected.org.name)
        expect(creator['affiliation']['affiliationIdentifierScheme']).to eql('ROR')
        expect(creator['affiliation']['affiliationIdentifier']).to eql(creator_ror.value)

        # Contributors check
        contrib = dmp_json['contributors'].first
        expected = @plan.contributors.last.reload
        expect(contrib['name']).to eql(expected.name)
        expect(contrib['nameType']).to eql('Personal')
        expect(contrib['contributorType']).to eql('ProjectLeader')
        expect(contrib['nameIdentifiers'].first['nameIdentifierScheme']).to eql('ORCID')
        expect(contrib['nameIdentifiers'].first['nameIdentifier'].end_with?(contrib_orcid.value)).to eql(true)
        expect(contrib['affiliation'].present?).to eql(true)
        expect(contrib['affiliation']['name']).to eql(expected.org.name)
        expect(contrib['affiliation']['affiliationIdentifierScheme']).to eql('ROR')
        expect(contrib['affiliation']['affiliationIdentifier']).to eql(contributor_ror.value)
      end
    end

    describe '#process_response(response:)' do
      it "returns nil if JSON for Datacite does not have ['data']" do
        resp = OpenStruct.new(body: { foo: 'bar' }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns nil if JSON for Datacite does not have ['data']['attributes']" do
        resp = OpenStruct.new(body: { data: { type: 'dmp_ids' } }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns nil if JSON for Datacite does not have ['data']['attributes']['relatedIdentifiers']" do
        resp = OpenStruct.new(body: { data: { attributes: { types: [] } } }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it 'returns nil if JSON is unparseable' do
        resp = OpenStruct.new(body: Faker::Lorem.sentence)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it 'returns the response as JSON' do
        expected = { data: { attributes: { doi: ['foo'] } } }
        resp = OpenStruct.new(body: expected.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(JSON.parse(expected.to_json))
      end
    end
  end
end
