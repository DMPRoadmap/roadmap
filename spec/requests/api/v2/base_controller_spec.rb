# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::BaseApiController do
  include ApiHelper

  describe 'GET /api/v2/me' do
    context 'OAuth (authorization_code grant type) — on behalf of a user' do
      before do
        @user = create(:user)
        @client = create(:oauth_application)
        token = mock_authorization_code_token(oauth_application: @client, user: @user).plaintext_token

        @headers = {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          Authorization: "Bearer #{token}"
        }
      end

      it 'returns 200 OK and user details when user is active' do
        get(api_v2_me_path, headers: @headers)

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['email']).to eq(@user.email)
        expect(json['firstname']).to eq(@user.firstname)
        expect(json['surname']).to eq(@user.surname)
        expect(json['organisation']).to eq(@user.org.name)
      end

      it 'returns 401 Unauthorized when user account is deactivated' do
        @user.update(active: false)

        get(api_v2_me_path, headers: @headers)

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json['errors']).to include('User account has been deactivated.')
      end
    end

    context 'when no authorization token is provided' do
      it 'returns 401 Unauthorized' do
        get(api_v2_me_path, headers: { Accept: 'application/json' })

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
