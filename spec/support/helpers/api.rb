# frozen_string_literal: true

module ApiHelper
  def mock_authorization_for_api_client
    api_client = ApiClient.first
    api_client = create(:api_client) unless api_client.present?

    Api::V1::BaseApiController.any_instance.stubs(:authorize_request).returns(true)
    Api::V1::BaseApiController.any_instance.stubs(:client).returns(api_client)
  end

  def mock_authorization_for_user(user: nil)
    create(:org) unless Org.any?
    user = User.org_admins(Org.last).first unless user.present?

    user = create(:user, :org_admin, api_token: SecureRandom.uuid, org: Org.last) unless user.present?

    Api::V1::BaseApiController.any_instance.stubs(:authorize_request).returns(true)
    Api::V1::BaseApiController.any_instance.stubs(:client).returns(user)
  end

  # API V2+ - Oauth authorization_code grant flow (on behalf of a user)
  def mock_authorization_code_token(oauth_application: create(:oauth_application), user: create(:user),
                                    scopes: 'read')
    create(:oauth_access_grant, application_id: oauth_application.id, resource_owner_id: user.id, scopes: scopes)
    create(:oauth_access_token, application: oauth_application, resource_owner_id: user.id, scopes: scopes)
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
      expect(next_json[:prev].present?).to be(true)
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
      expect(prev_json[:next].present?).to be(true)
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
