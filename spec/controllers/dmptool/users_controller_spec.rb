# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::UsersController, type: :request do
  before(:each) do
    @controller = ::UsersController.new
  end

  it 'UsersController includes our customizations' do
    expect(@controller.respond_to?(:revoke_oauth_access_token)).to eql(true)
  end

  describe 'DELETE /users/:user_id/oauth_credential_tokens/:id - :revoke_oauth_access_token' do

  end

  describe 'GET /users/third_party_apps - :third_party_apps' do
    it 'it is not accessible when not logged in' do
      get users_third_party_apps_path
      expect(response).to have_http_status(:not_authorized)
      expect(response).to redirect_to(root_path)
    end
    it 'is accessible when logged in' do
      sign_in(create(:user))
      get users_third_party_apps_path
      expect(response).to have_http_status(:success)
      expect(response.body.include?('<h1>3rd Party Applications')).to eql(true)
    end
  end

  describe 'GET /users/developer_tools - :developer_tools' do
    it 'it is not accessible when not logged in' do
      get users_developer_tools_path
      expect(response).to have_http_status(:not_authorized)
      expect(response).to redirect_to(root_path)
    end
    it 'is accessible when logged in' do
      sign_in(create(:user))
      get users_developer_tools_path
      expect(response).to have_http_status(:success)
      expect(response.body.include?('<h1>Developer Tools')).to eql(true)
    end
  end
end
