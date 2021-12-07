# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::RelatedIdentifiersController, type: :request do
  include Api::AccessTokenRequestHelper
  include Api::AuthorizationRequestHelper

  before(:each) do
    @other_user = create(:user)

    @plan = create(:plan, :creator, :privately_visible, complete: true)

    @client = create(:api_client, trusted: false,
                                  user: create(:user, :org_admin, org: create(:org)))
    token = client_is_authorized(@client, @plan.owner, { scopes: "edit_dmps" })
    resource_owner_is_authenticated(@plan.owner)

    @headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer #{token.token}"
    }
  end

  describe 'POST /api/v2/related_identifiers - create' do
    before(:each) do
      @json = {
        dmp: {
          dmp_id: {
            type: 'url',
            identifier: Rails.application.routes.url_helpers.api_v2_plan_url(@plan)
          },
          dmproadmap_related_identifiers: [
            {
              descriptor: RelatedIdentifier.relation_types.keys.sample,
              type: RelatedIdentifier.identifier_types.keys.sample,
              work_type: RelatedIdentifier.work_types.keys.sample,
              identifier: Faker::Internet.unique.url
            }, {
              descriptor: RelatedIdentifier.relation_types.keys.sample,
              type: RelatedIdentifier.identifier_types.keys.sample,
              identifier: Faker::Internet.unique.url
            }
          ]
        }
      }
    end

    it 'returns a 401 if the access token is invalid' do
      @headers['Authorization'] = "Bearer #{SecureRandom.uuid}"
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql('401')
      expect(response).to render_template('api/v2/_standard_response')
      expect(response).to render_template('api/v2/error')
    end
    it 'returns a 404 if the Plan does not exist' do
      @json[:dmp][:dmp_id][:identifier] = SecureRandom.uuid
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql('404')
      expect(response).to render_template('api/v2/error')
    end
    it 'returns a 404 if the resource owner does not own the Plan' do
      Role.where(plan: @plan, user: @plan.owner).update(user: @other_user)
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql('404')
      expect(response).to render_template('api/v2/error')
    end
    it 'returns a 400 if the incoming JSON is invalid' do
      post api_v2_related_identifiers_path, params: { foo: 'bar' }.to_json, headers: @headers
      expect(response.code).to eql('400')
      expect(response).to render_template('api/v2/error')
    end
    it 'returns a 400 if the incoming RelatedIdentifier is invalid' do
      @json[:dmp][:dmproadmap_related_identifiers].first.delete(:type)
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql('400')
      expect(response).to render_template('api/v2/error')
    end
    it 'skips RelatedIdentifiers that already exist' do
      id = @json[:dmp][:dmproadmap_related_identifiers].first[:identifier]
      r_id = create(:related_identifier, identifiable: @plan, value: id,
                                         updated_at: Time.now - 2.days)
      last_updated = r_id.updated_at
      @plan.reload
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("201")
      expect(response).to render_template("api/v2/plans/index")
      expect(r_id.reload.updated_at).to eql(last_updated)
    end
    it 'returns a 201 if the incoming JSON is valid' do
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("201")
      expect(response).to render_template("api/v2/plans/index")
      json = JSON.parse(response.body).with_indifferent_access
                 .fetch(:items, [{}])
                 .first[:dmp]
      r_ids = json.fetch(:dmproadmap_related_identifiers, [])
      expect(json[:dmp_id]).to eql(JSON.parse(@json[:dmp][:dmp_id].to_json))
      r_ids = r_ids.map { |related| related[:identifier] }
      expected = @json[:dmp][:dmproadmap_related_identifiers].map { |i| i[:identifier] }
      r_ids.each { |rid| expect(expected.include?(rid)).to eql(true) }
    end
    it "logs the addition of the new related identifier in the api_logs" do
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      entry = ApiLog.all.last
      related = RelatedIdentifier.all.last
      expected = "Created a new RelatedIdentifier:<br>#<RelatedIdentifier id: #{related.id}, "
      expect(entry.present?).to eql(true)
      expect(entry.api_client_id).to eql(@client.id)
      expect(entry.logable).to eql(related)
      expect(entry.change_type).to eql('added')
      expect(entry.activity.start_with?(expected)).to eql(true)
    end
  end
end
