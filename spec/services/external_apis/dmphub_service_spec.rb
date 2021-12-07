# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::DmphubService, type: :model do
  include DmphubMocks
  include IdentifierHelper

  before(:each) do
    Rails.configuration.x.dmphub.active = true
    Rails.configuration.x.dmphub.api_base_url = 'https://api.test.dmphub.org/'
    Rails.configuration.x.madmp.enable_dmp_id_registration = true
    unless Language.where(default_language: true).any?
      # Org model requires a language so make sure the default is set
      create(:language, default_language: true)
    end
    @plan = create(:plan, :creator)
    create(:contributor, investigation: true, plan: @plan)
    create_dmp_id(plan: @plan)
    @client = create(:api_client)

    described_class.stubs(:api_client).returns(@client)

    @dmp_id = @plan.dmp_id.value_without_scheme_prefix
    @plan.reload
  end

  describe '#mint_dmp_id' do
    it 'returns nil if the DMPHubService is not active' do
      Rails.configuration.x.dmphub.active = false
      expect(described_class.mint_dmp_id(plan: @plan)).to eql(nil)
    end
    it 'returns nil if :auth returns nil' do
      stub_auth_error!
      expect(described_class.mint_dmp_id(plan: @plan)).to eql(nil)
    end
    it 'returns nil if :plan is not present' do
      stub_auth_success!
      expect(described_class.mint_dmp_id(plan: nil)).to eql(nil)
    end
    it 'handles the http failure and notifies admins if HTTP response is not 200' do
      stub_auth_success!
      stub_minting_error!
      described_class.expects(:handle_http_failure).returns(true)
      described_class.expects(:notify_administrators).returns(true)
      result = described_class.mint_dmp_id(plan: @plan)
      expect(result).to eql(nil)
    end
    it 'processes the response, updates the subscription and returns the DMP ID' do
      stub_auth_success!
      stub_minting_success!
      described_class.expects(:process_response).returns('foo')
      described_class.expects(:add_subscription).returns(true)
      result = described_class.mint_dmp_id(plan: @plan)
      expect(result).to eql('foo')
    end
  end

  describe '#update_dmp_id(plan:)' do
    it 'returns nil if the DMPHubService is not active' do
      Rails.configuration.x.dmphub.active = false
      expect(described_class.update_dmp_id(plan: @plan)).to eql(nil)
    end
    it 'returns nil if :auth returns nil' do
      stub_auth_error!
      expect(described_class.update_dmp_id(plan: @plan)).to eql(nil)
    end
    it 'returns nil if :plan is not present' do
      stub_auth_success!
      expect(described_class.update_dmp_id(plan: nil)).to eql(nil)
    end
    it 'handles the http failure and notifies admins if HTTP response is not 200' do
      stub_auth_success!
      stub_update_error!
      described_class.expects(:handle_http_failure).returns(true)
      described_class.expects(:notify_administrators).returns(true)
      result = described_class.update_dmp_id(plan: @plan)
      expect(result).to eql(nil)
    end
    it 'processes the response, updates the subscription and returns the DMP ID' do
      stub_auth_success!
      stub_update_success!
      described_class.expects(:process_response).returns('foo')
      described_class.expects(:update_subscription).returns(true)
      result = described_class.update_dmp_id(plan: @plan)
      expect(result).to eql('foo')
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
      described_class.expects(:callback_path).returns('https://doi.org/123.123/%<dmp_id>s')
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
      it 'handles a successful auth' do
        stub_auth_success!
        described_class.expects(:process_token).returns({ foo: 'bar' })
        expect(described_class.send(:auth).present?).to eql(true)
      end

      it 'handles an unsuccessful auth' do
        stub_auth_error!
        described_class.expects(:process_token).never
        expect(described_class.send(:auth).present?).to eql(false)
      end
    end

    describe '#process_token(json:)' do
      before(:each) do
        @token_hash = { token_type: Faker::Lorem.word, access_token: SecureRandom.uuid }
      end

      it 'returns nil if :json does not include an :token_type' do
        @token_hash[:token_type] = nil
        expect(described_class.send(:process_token, json: @token_hash.to_json)).to eql(nil)
      end
      it 'returns nil if :json does not include an :access_token' do
        @token_hash[:access_token] = nil
        expect(described_class.send(:process_token, json: @token_hash.to_json)).to eql(nil)
      end
      it 'logs JSON parser errors' do
        JSON.expects(:parse).raises(JSON::ParserError.new('foo'))
        Rails.logger.expects(:error).twice
        result = described_class.send(:process_token, json: @token_hash.to_json)
        expect(result).to eql(nil)
      end
      it "formats the token info for the 'Authorization' header" do
        expected = "#{@token_hash[:token_type]}: #{@token_hash[:access_token]}"
        result = described_class.send(:process_token, json: @token_hash.to_json)
        expect(result).to eql(expected)
      end
    end
    describe '#json_from_template(dmp:)' do
      it 'properly generates the JSON for submission to DMPHub' do
        ActionController::Base.any_instance.expects(:render_to_string)
                              .with(
                                partial: '/api/v1/plans/show',
                                locals: { plan: @plan, client: @client }
                              )
                              .returns({ foo: 'bar' }.to_json)
        result = described_class.send(:json_from_template, plan: @plan)
        expect(result).to eql('{"dmp":{"foo":"bar"}}')
      end
    end

    # rubocop:disable Style/OpenStructUse
    describe '#process_response(response:)' do
      it "returns nil if JSON for DMPHub does not have ['items']" do
        resp = OpenStruct.new(body: { foo: 'bar' }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns nil if JSON for DMPHub does not have ['items'].first['dmp']" do
        resp = OpenStruct.new(body: { items: [{ foo: 'bar' }] }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it "returns nil if JSON for DMPHub does not have ['items'].first['dmp']['dmp_id']" do
        resp = OpenStruct.new(body: { items: [{ dmp: { title: 'foo' } }] }.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it 'returns nil if JSON is unparseable' do
        resp = OpenStruct.new(body: Faker::Lorem.sentence)
        expect(described_class.send(:process_response, response: resp)).to eql(nil)
      end
      it 'returns the response as JSON' do
        expected = { items: [{ dmp: { dmp_id: { type: 'doi', identifier: '123' } } }] }
        resp = OpenStruct.new(body: expected.to_json)
        expect(described_class.send(:process_response, response: resp)).to eql('123')
      end
    end
    # rubocop:enable Style/OpenStructUse
  end
end
