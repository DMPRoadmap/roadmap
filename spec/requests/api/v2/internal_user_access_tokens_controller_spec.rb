# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::InternalUserAccessTokensController do
  let(:user) { create(:user) }
  let(:app_name) { Rails.application.config.x.application.internal_oauth_app_name }
  let!(:oauth_app) { create(:oauth_application, name: app_name) }

  describe 'POST #create' do
    def post_create_token
      post api_v2_internal_user_access_token_path
    end

    context 'when user is not authenticated' do
      # In production, CSRF protection would reject the request with a 422 error
      # before it reaches Pundit. However, RSpec bypasses CSRF checks, so this
      # test verifies that Pundit raises NotDefinedError when authorize is called
      # with nil. This error won't occur in production due to CSRF protection.
      it 'raises Pundit::NotDefinedError and does not create a token' do
        expect do
          expect do
            post_create_token
          end.to raise_error(Pundit::NotDefinedError)
        end.not_to change { Doorkeeper::AccessToken.count }
      end
    end

    context 'when user is authenticated' do
      before { sign_in(user) }

      it 'rotates the user token' do
        post_create_token

        expect(response).to have_http_status(:ok)
      end

      it 'creates a new token' do
        expect do
          post_create_token
        end.to change { Doorkeeper::AccessToken.count }.by(1)
      end

      it 'assigns the plaintext token' do
        post_create_token

        expect(assigns(:v2_token)).to be_a(String)
        expect(assigns(:v2_token)).not_to be_blank
      end

      it 'renders the refresh_token template' do
        post_create_token

        expect(response).to render_template('users/refresh_token')
      end

      context 'when a token already exists' do
        let!(:old_token) do
          create(:oauth_access_token, application: oauth_app, resource_owner_id: user.id, scopes: 'read')
        end

        it 'revokes the old token' do
          post_create_token

          old_token.reload
          expect(old_token.revoked_at).not_to be_nil
        end

        it 'creates a new token' do
          post_create_token

          new_token = assigns(:token)
          expect(new_token).not_to eq(old_token)
        end
      end
    end

    context 'when the internal OAuth application is missing' do
      before do
        sign_in(user)
        oauth_app.destroy
      end

      it 'raises a StandardError' do
        expect do
          post_create_token
        end.to raise_error(StandardError, /not found/)
      end
    end
  end
end
