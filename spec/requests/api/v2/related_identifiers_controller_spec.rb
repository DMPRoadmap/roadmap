# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::RelatedIdentifiersController, type: :request do

  include Api::AccessTokenRequestHelper
  include Api::AuthorizationRequestHelper

  before(:each) do
    @other_user = create(:user)

    @plan = create(:plan, :creator)

    @client = create(:api_client, trusted: false,
                                  user: create(:user, :org_admin, org: create(:org)))
    token = client_is_authorized(@client, @plan.owner, { scopes: "edit_dmps" })
    resource_owner_is_authenticated(@plan.owner)

    @headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer #{token.to_s}"
    }
  end

  describe "POST /api/v2/related_identifiers - create" do
    before(:each) do
      @json = {
        dmp: {
          dmp_id: {
            type: "url",
            identifier: Rails.application.routes.url_helpers.api_v2_plan_url(@plan)
          },
          dmproadmap_related_identifiers: [
            {
              descriptor: RelatedIdentifier.relation_types.keys.sample,
              type: RelatedIdentifier.identifier_types.keys.sample,
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

    it "returns a 401 if the access token is invalid" do
      @headers["Authorization"] = "Bearer #{SecureRandom.uuid}"
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("401")
      expect(response).to render_template("api/v2/_standard_response")
      expect(response).to render_template("api/v2/error")
    end
    it "returns a 404 if the Plan does not exist" do
      @json[:dmp][:dmp_id][:identifier] = SecureRandom.uuid
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("404")
      expect(response).to render_template("api/v2/error")
    end
    it "returns a 404 if the resource owner does not own the Plan" do
      Role.where(plan: @plan, user: @plan.owner).update(user: @other_user)
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("404")
      expect(response).to render_template("api/v2/error")
    end
    it "returns a 400 if the incoming JSON is invalid" do
      post api_v2_related_identifiers_path, params: { foo: "bar" }.to_json, headers: @headers
      expect(response.code).to eql("400")
      expect(response).to render_template("api/v2/error")
    end
    it "returns a 400 if the incoming RelatedIdentifier is invalid" do
      @json[:dmp][:dmproadmap_related_identifiers].first.delete(:type)
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("400")
      expect(response).to render_template("api/v2/error")
    end
    it "skips RelatedIdentifiers that already exist" do
      id = @json[:dmp][:dmproadmap_related_identifiers].first[:identifier]
      r_id = create(:related_identifier, identifiable: @plan, value: id)
      @plan.reload
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("201")
      expect(response).to render_template("api/v2/plans/show")
      r_ids = JSON.parse(response.body)
                  .fetch(:items, [{}])
                  .first[:dmp][:dmproadmap_related_identifiers]
      r_ids = r_ids.map { |related| related[:identifier] }
      expected = @json[:dmp][:dmproadmap_related_identifiers].map { |i| i[:identifier] }
      expect(r_ids).to eql(expected)
    end
    it "returns a 201 if the incoming JSON is valid" do
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      expect(response.code).to eql("201")
      expect(response).to render_template("api/v2/plans/show")
      r_ids = JSON.parse(response.body)
                  .fetch(:items, [{}])
                  .first[:dmp][:dmproadmap_related_identifiers]
      expect(r_ids).to eql(@json[:dmp][:dmproadmap_related_identifiers])
    end
    it "logs the addition of the new related identifier in the api_logs" do
      post api_v2_related_identifiers_path, params: @json.to_json, headers: @headers
      entry = ApiLog.all.last
      expect(entry.present?).to eql(true)
      expect(entry.api_client_id).to eql(ApiClient.all.last)
      expect(entry.logable).to eql(@plan)
      expect(entry.change_type).to eql('added')
      expect(entry.activity).to eql(nil)
    end
  end

end
