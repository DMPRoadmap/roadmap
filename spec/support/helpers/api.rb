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

    unless user.present?
      user = create(:user, :org_admin, api_token: SecureRandom.uuid, org: Org.last)
    end

    Api::V1::BaseApiController.any_instance.stubs(:authorize_request).returns(true)
    Api::V1::BaseApiController.any_instance.stubs(:client).returns(user)
  end

end
