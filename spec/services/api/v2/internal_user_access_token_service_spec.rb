# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::InternalUserAccessTokenService do
  let(:user) { create(:user) }
  let(:app_name) { Rails.application.config.x.application.internal_oauth_app_name }
  let!(:oauth_app) { create(:oauth_application, name: app_name) }

  def create_internal_user_access_token
    create(:oauth_access_token, application: oauth_app, resource_owner_id: user.id, scopes: 'read')
  end

  describe '#for_user' do
    context 'when a token exists for the user' do
      let!(:access_token) do
        create_internal_user_access_token
      end

      it 'returns the access token' do
        token = described_class.for_user(user)
        expect(token).to be_present
        expect(token.resource_owner_id).to eq(user.id)
      end
    end

    context 'when no token exists for the user' do
      it 'returns nil' do
        token = described_class.for_user(user)
        expect(token).to be_nil
      end
    end
  end

  describe '#rotate!' do
    def rotate_token_expectations(new_token, old_token = nil) # rubocop:disable Metrics/AbcSize
      expect(new_token).to be_persisted
      expect(new_token.resource_owner_id).to eq(user.id)
      expect(new_token.revoked_at).to be_nil
      expect(new_token.scopes.to_s).to include('read')
      return unless old_token

      expect(new_token).not_to eq(old_token)
      expect(old_token.revoked_at).not_to be_nil
    end

    context 'when a token already exists' do
      let!(:old_token) do
        create_internal_user_access_token
      end

      it 'revokes the old token and creates a new one' do
        new_token = described_class.rotate!(user)
        old_token.reload
        rotate_token_expectations(new_token, old_token)
      end
    end

    context 'when no token exists' do
      it 'creates a new token' do
        token = described_class.rotate!(user)
        rotate_token_expectations(token)
      end
    end
  end

  describe '#application_present?' do
    context 'when the app exists' do
      it 'returns true' do
        expect(described_class.application_present?).to be true
      end
    end

    context 'when the app does not exist' do
      before { oauth_app.destroy }

      it 'returns false' do
        expect(described_class.application_present?).to be false
      end
    end
  end
end
