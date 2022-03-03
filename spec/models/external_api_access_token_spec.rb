# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApiAccessToken, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:external_service_name) }
    it { is_expected.to validate_presence_of(:access_token) }

    it "should validate that a User can only have one 'active' token per external service" do
      user = create(:user)
      subject = build(:external_api_access_token, user: user)
      subject.valid?
      err = subject.errors.full_messages.include?(_('only one active access token allowed per user / service'))
      expect(err)
    end
  end

  context 'class_methods' do
    describe '#for_user_and_service(user:, service:)' do
      before(:each) do
        @user = create(:user)
        @svc = 'FOOBAR'
        @expired_token = create(:external_api_access_token, user: @user, external_service_name: @svc.downcase,
                                                            expires_at: Time.now - 1.days)
        @revoked_token = create(:external_api_access_token, user: @user, external_service_name: @svc.downcase,
                                                            revoked_at: Time.now - 1.days)
        @active_token = create(:external_api_access_token, user: @user, external_service_name: @svc.downcase,
                                                           revoked_at: nil, expires_at: nil)
      end
      it 'returns nil if the user has no active token' do
        expect(described_class.for_user_and_service(user: create(:user), service: @svc)).to eql(nil)
      end
      it 'returns nil if the user has no active tokens for the specified service' do
        expect(described_class.for_user_and_service(user: @user, service: 'foo')).to eql(nil)
      end
      it 'returns the active token' do

p "USER: #{@user.inspect}"
p "SERVICE: #{@svc.inspect}"
p "ACTIVE TOKEN: #{@active_token.inspect}"

        expect(described_class.for_user_and_service(user: @user, service: @svc)).to eql(@active_token)
      end
    end

    describe '#from_omniauth(user:, service:, hash:)' do
      before(:each) do
        @user = create(:user)
        @svc = Faker::Lorem.unique.word.upcase

        @old_token = create(:external_api_access_token, user: @user, external_service_name: @svc.downcase)
        @hash = {
          credentials: {
            token: SecureRandom.uuid,
            refresh_token: SecureRandom.uuid,
            expires_at: [3600, 86_400, 604_800, 2_629_746, 7_889_238, 631_138_518, 2_250_680_850].sample
          }
        }
      end

      it 'returns nil unless the user is present' do
        expect(described_class.from_omniauth(user: nil, service: @svc, hash: @hash)).to eql(nil)
      end
      it 'returns nil unless the user is not a User' do
        expect(described_class.from_omniauth(user: build(:org), service: @svc, hash: @hash)).to eql(nil)
      end
      it 'returns nil unless :service is present' do
        expect(described_class.from_omniauth(user: @user, service: nil, hash: @hash)).to eql(nil)
      end
      it 'returns nil unless :hash is present' do
        expect(described_class.from_omniauth(user: @user, service: @svc, hash: nil)).to eql(nil)
      end
      it 'returns nil unless :hash[:credentials][:token] is present' do
        @hash[:credentials].delete(:token)
        expect(described_class.from_omniauth(user: @user, service: @svc, hash: @hash)).to eql(nil)
      end
      it 'revokes existing tokens' do
        expect(@old_token.reload.revoked_at).to eql(nil)
        described_class.from_omniauth(user: @user, service: @svc, hash: @hash)
        expect(@old_token.reload.revoked_at).not_to eql(nil)
      end
      it 'sets the :expires_at to nil if the hash contains no expiry time' do
        @hash[:credentials].delete(:expires_at)
        token = described_class.from_omniauth(user: @user, service: @svc, hash: @hash)
        expect(token.expires_at).to eql(nil)
      end
      it 'creates a new token' do
        token = described_class.from_omniauth(user: @user, service: @svc, hash: @hash)
        expect(token.user).to eql(@user)
        expect(token.external_service_name).to eql(@svc.downcase)
        expect(token.access_token).to eql(@hash[:credentials][:token])
        expect(token.refresh_token).to eql(@hash[:credentials][:refresh_token])
        expected = (Time.now + @hash[:credentials][:expires_at].to_i.seconds).utc.strftime('%Y-%m-%d %H:%m')
        expect(token.expires_at.strftime('%Y-%m-%d %H:%m')).to eql(expected)
      end
    end
  end

  context 'instance methods' do
    describe '#revoke!' do
      it 'sets :revoked_at' do
        token = create(:external_api_access_token, user: create(:user))
        expect(token.revoked_at).to eql(nil)
        token.revoke!
        expect(token.revoked_at).not_to eql(nil)
      end
    end

    describe '#active?' do
      it 'returns false if the token has expired' do
        token = build(:external_api_access_token, revoked_at: nil, expires_at: Time.now - 2.hours)
        expect(token.active?).to eql(false)
      end
      it 'returns false if the token has been revoked' do
        token = build(:external_api_access_token, revoked_at: Time.now - 2.hours)
        expect(token.active?).to eql(false)
      end
      it 'returns true if the token is not revoked or expired' do
        token = build(:external_api_access_token, revoked_at: nil, expires_at: Time.now + 2.hours)
        expect(token.active?).to eql(true)
      end
    end
  end
end
