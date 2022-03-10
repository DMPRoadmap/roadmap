# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::TemplatesController, type: :request do
  include ApiHelper

  before(:each) do
    @client = create(:api_client, user: create(:user, org: create(:org)))
    token = mock_client_credentials_token(api_client: @client)

    @headers = {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      Authorization: "Bearer #{token}"
    }
    # Org model requires a language so make sure the default is set
    create(:language, default_language: true) unless Language.default.present?
  end

  describe 'GET /api/v2/templates (index)' do
    it 'returns 401 if the token is invalid' do
      @headers['Authorization'] = "Bearer #{SecureRandom.uuid}"
      get(api_v2_templates_path, headers: @headers)

      expect(response.code).to eql('401')
      expect(response).to render_template('api/v2/_standard_response')
      expect(response).to render_template('api/v2/error')

      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:items].empty?).to eql(true)
      expect(json[:errors].length).to eql(1)
      expect(json[:errors].first).to eql('token is invalid, expired or has been revoked')
    end
    it 'returns an empty array if no templates are available' do
      get(api_v2_templates_path, headers: @headers)

      expect(response.code).to eql('200')
      expect(response).to render_template('api/v2/_standard_response')
      expect(response).to render_template('api/v2/templates/index')

      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:items].empty?).to eql(true)
      expect(json[:errors].nil?).to eql(true)
    end
    it 'returns the expected templates when ApiClient has a User.org association' do
      @org = @client.user.org

      # Publicly visible templates
      public_published = create(:template, visibility: 1, published: true, org: create(:org))
      create(:template, visibility: 1, published: false, org: create(:org))

      # Organisationally visible templates owned by another Org
      create(:template, visibility: 0, published: true, org: create(:org))
      create(:template, visibility: 0, published: false, org: create(:org))

      # Organisationally visible templates owned by the ApiClient's Org
      my_org_published = create(:template, visibility: 0, published: true, org: @org)
      create(:template, visibility: 0, published: false, org: @org)

      # Customizations
      create(:template, visibility: 1, published: true, org: create(:org),
                        customization_of: public_published.family_id)
      my_org_customization = create(:template, visibility: 1, published: true, org: @org,
                                               customization_of: public_published.family_id)

      get(api_v2_templates_path, headers: @headers)
      expect(response.code).to eql('200')
      expect(response).to render_template('api/v2/_standard_response')
      expect(response).to render_template('api/v2/templates/index')

      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:items].length).to eql(3)

      # Only the Publicly visible template, Api Client's Org's template, and the Api Client Org's
      # customizations should be returned!
      ids = json[:items].map { |item| item[:dmp_template][:template_id][:identifier] }
      expect(ids.include?(public_published.family_id.to_s)).to eql(true)
      expect(ids.include?(my_org_published.family_id.to_s)).to eql(true)
      expect(ids.include?(my_org_customization.family_id.to_s)).to eql(true)
    end

    it 'returns the expected templates when ApiClient has no User.org association' do
      @client.update(user: nil)

      # Publicly visible templates
      public_published = create(:template, visibility: 1, published: true, org: create(:org))
      create(:template, visibility: 1, published: false, org: create(:org))

      # Organisationally visible templates owned by another Org
      create(:template, visibility: 0, published: true, org: create(:org))
      create(:template, visibility: 0, published: false, org: create(:org))

      # Customizations
      create(:template, visibility: 1, published: true, org: create(:org),
                        customization_of: public_published.family_id)

      get(api_v2_templates_path, headers: @headers)
      expect(response.code).to eql('200')
      expect(response).to render_template('api/v2/_standard_response')
      expect(response).to render_template('api/v2/templates/index')

      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:items].length).to eql(1)

      # Only the Publicly visible template, Api Client's Org's template, and the Api Client Org's
      # customizations should be returned!
      ids = json[:items].map { |item| item[:dmp_template][:template_id][:identifier] }
      expect(ids.include?(public_published.family_id.to_s)).to eql(true)
    end

    it 'allows for paging' do
      21.times { create(:template, visibility: 1, published: true) }
      get(api_v2_templates_path, headers: @headers)

      test_paging(json: JSON.parse(response.body), headers: @headers)
    end
  end
end
