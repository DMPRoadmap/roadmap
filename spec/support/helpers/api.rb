# frozen_string_literal: true

module ApiHelper
  SCOPES = Doorkeeper.config.default_scopes + Doorkeeper.config.optional_scopes

  # API V1 - auth for an ApiClient (client_id + client_secret)
  def mock_authorization_for_api_client
    api_client = ApiClient.first
    api_client = create(:api_client) unless api_client.present?

    Api::V1::BaseApiController.any_instance.stubs(:authorize_request).returns(true)
    Api::V1::BaseApiController.any_instance.stubs(:client).returns(api_client)
  end

  # API V1 - auth for a User (email + api token)
  def mock_authorization_for_user(user: nil)
    create(:org) unless Org.any?
    user = User.org_admins(Org.last).first unless user.present?

    user = create(:user, :org_admin, api_token: SecureRandom.uuid, org: Org.last) unless user.present?

    Api::V1::BaseApiController.any_instance.stubs(:authorize_request).returns(true)
    Api::V1::BaseApiController.any_instance.stubs(:client).returns(user)
  end

  # API V2+ - Oauth client_credentials grant flow
  def mock_client_credentials_token(api_client: create(:api_client), scopes: SCOPES)
    create(:oauth_access_token, application: api_client, scopes: scopes).token
  end

  # API V2+ - Oauth authorization_code grant flow (on behalf of a user)
  def mock_authorization_code_token(api_client: create(:api_client), user: create(:user))
    create(:oauth_access_grant, application: api_client, resource_owner_id: user.id)
    create(:oauth_access_token, application: api_client, resource_owner_id: user.id).token
  end

  # Tests the standard pagination functionality
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_paging(json: {}, headers: {})
    json = json.with_indifferent_access
    original = json[:items].first

    if json[:next].present?
      # Move to the next page
      get(json[:next], headers: headers)
      expect(response.code).to eql('200')
      next_json = JSON.parse(response.body).with_indifferent_access
      expect(next_json[:prev].present?).to eql(true)
      expect(next_json[:items].first).not_to eql(original)

      # Move back to previous page
      get(next_json[:prev], headers: headers)
      expect(response.code).to eql('200')
      prev_json = JSON.parse(response.body).with_indifferent_access
      expect(prev_json[:items].first).to eql(original)
    elsif json[:prev].present?
      get(json[:prev], headers: headers)
      expect(response.code).to eql('200')
      prev_json = JSON.parse(response.body).with_indifferent_access
      expect(prev_json[:next].present?).to eql(true)
      expect(next_json[:items].first).not_to eql(original)

      get(prev_json[:next], headers: headers)
      expect(response.code).to eql('200')
      next_json = JSON.parse(response.body).with_indifferent_access
      expect(next_json[:items].first).to eql(original)
    else
      raise StandardError, 'Expected to test API pagination but there are not enough items!'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
