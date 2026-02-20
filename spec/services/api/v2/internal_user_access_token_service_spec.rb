# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::InternalUserAccessTokenService do
  let(:user) { create(:user) }
  let(:app_name) { Rails.application.config.x.application.internal_oauth_app_name }
  let!(:oauth_app) { create(:oauth_application, name: app_name) }

  def create_internal_user_access_token
    create(:oauth_access_token, application: oauth_app, resource_owner_id: user.id, scopes: 'read')
  end

  describe '#rotate!' do
    def rotate_token_expectations(plaintext_token, old_token = nil) # rubocop:disable Metrics/AbcSize
      # Doorkeeper hashes token via Digest::SHA256
      hashed = Digest::SHA256.hexdigest(plaintext_token)
      new_token = Doorkeeper::AccessToken.find_by!(token: hashed)
      expect(new_token).to be_present
      expect(new_token.resource_owner_id).to eq(user.id)
      expect(new_token.revoked_at).to be_nil
      expect(new_token.scopes.to_s).to include('read')
      expect(old_token.revoked_at).not_to be_nil if old_token
    end

    shared_examples 'token rotation' do |has_old_token|
      it "#{if has_old_token
              'revokes the old token and creates a new one'
            else
              'creates a new token'
            end}
      (returns plaintext)" do
        plaintext_token = nil
        # Ensure .rotate!(user) creates a new AccessToken db entry for user
        expect { plaintext_token = described_class.rotate!(user) }
          .to change { Doorkeeper::AccessToken.where(resource_owner_id: user.id).count }
          .by(1)
        if has_old_token
          old_token.reload
          rotate_token_expectations(plaintext_token, old_token)
        else
          rotate_token_expectations(plaintext_token)
        end
      end
    end

    context 'when a token already exists' do
      let!(:old_token) { create_internal_user_access_token }
      include_examples 'token rotation', true
    end

    context 'when no token exists' do
      include_examples 'token rotation', false
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
