# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/ModuleLength
module Dmptool
  RSpec.describe User do
    include IdentifierHelper
    include EmailHelper

    context 'class methods' do
      describe 'invite!(inviter:, plan:, params:)' do
        before(:each) do
          @plan = create(:plan, :creator)
          @inviter = @plan.owner
          @params = { email: Faker::Internet.email }

          clear_emails
        end

        it 'returns nil if inviter is not present' do
          expect(::User.invite!(inviter: nil, plan: @plan, params: @params)).to eql(nil)
        end
        it 'returns nil if plan is not present' do
          expect(::User.invite!(inviter: @inviter, plan: nil, params: @params)).to eql(nil)
        end
        it 'returns nil if params are not present' do
          expect(::User.invite!(inviter: @inviter, plan: @plan, params: nil)).to eql(nil)
        end
        it 'returns nil if params[:email] is not present' do
          expect(::User.invite!(inviter: @inviter, plan: @plan, params: {})).to eql(nil)
        end
        it 'uses the specified params' do
          @params[:org_id] = create(:org).id
          @params[:firstname] = Faker::Movies::StarWars.unique.character.split.first
          @user = ::User.invite!(inviter: @inviter, plan: @plan, params: @params)
          expect(@user.firstname).to eql(@params[:firstname])
          expect(@user.org_id).to eql(@params[:org_id])
        end
        it 'update the User with the default values' do
          @user = ::User.invite!(inviter: @inviter, plan: @plan, params: @params)
          expect(@user.firstname).to eql('First')
          expect(@user.surname).to eql('Last')
          expect(@user.password.present?).to eql(true)
          expect(@user.invitation_token.present?).to eql(true)
          expect(@user.invitation_created_at.present?).to eql(true)
          expect(@user.invitation_sent_at.present?).to eql(true)
          expect(@user.invited_by_id).to eql(@inviter.id)
          expect(@user.invited_by_type).to eql(@inviter.class.name)
          expect(@user.org_id).to eql(@inviter.org_id)
          expect(@user.invitation_plan_id).to eql(@plan.id)
        end
        it 'sends the email invitation' do
          @user = ::User.invite!(inviter: @inviter, plan: @plan, params: @params)
          expect(sent_emails).to have_exactly(1).item
          email = sent_emails.first
          expect(email.to).to eql([@params[:email]])
          expected = _('A Data Management Plan in the DMPTool-Dev has been shared with you')
          expect(email.subject).to eql(expected)
          expect(email.body.include?(@inviter.name(false))).to eql(true)
          expect(email.body.include?(@plan.title))
        end
      end

      describe 'from_omniauth(scheme)' do
        # TODO: Implement this
      end

      describe 'omniauth_from_request' do
        # TODO: This should probably be in the controller and the params passed into this module
      end

      describe 'extract_omniauth_email(hash:)' do
        # TODO: This should probably be in the controller and the params passed into this module
      end

      describe 'extract_omniauth_names(hash:)' do
        # TODO: This should probably be in the controller and the params passed into this module
      end
    end

    context 'instance methods' do
      describe 'active_invitation?' do
        it 'returns false if the user has not been invited' do
          user = build(:user)
          expect(user.active_invitation?).to eql(false)
        end
        it 'returns false if the invitation has already been accepted' do
          user = build(:user, invitation_token: SecureRandom.uuid,
                              invitation_created_at: Time.now - 2.days,
                              invitation_sent_at: Time.now - 2.days,
                              invitation_accepted_at: Time.now)
          expect(user.active_invitation?).to eql(false)
        end
        it 'returns true if the user has an invitation' do
          user = build(:user, invitation_token: SecureRandom.uuid,
                              invitation_created_at: Time.now - 2.days,
                              invitation_sent_at: Time.now - 2.days)
          expect(user.active_invitation?).to eql(true)
        end
      end

      describe 'accept_invitation' do
        it 'returns false if the user does not have an active invitation' do
          user = build(:user)
          expect(user.accept_invitation).to eql(false)
        end
        it 'updates the :invitation_accepted_at date time' do
          user = build(:user, invitation_token: SecureRandom.uuid,
                              invitation_created_at: Time.now - 2.days,
                              invitation_sent_at: Time.now - 2.days)
          expect(user.invitation_accepted_at.nil?).to eql(true)
          expect(user.accept_invitation).to eql(true)
          expect(user.invitation_accepted_at.nil?).to eql(false)
        end
      end

      describe 'access_token_for(external_service_name:)' do
        it 'returns nil if the :external_service_name is not present' do
          user = build(:user)
          expect(user.access_token_for(external_service_name: nil)).to eql(nil)
        end
        it 'returns nil if the user has no :external_api_tokens' do
          user = build(:user)
          expect(user.access_token_for(external_service_name: 'orcid')).to eql(nil)
        end
        it 'returns nil if there is no token for the specified :external_service_name' do
          user = build(:user)
          token = build(:external_api_access_token, external_service_name: 'other_system')
          user.external_api_access_tokens << token
          expect(user.access_token_for(external_service_name: 'orcid')).to eql(nil)
        end
        it 'returns the external_api_token for the specified :external_service_name' do
          user = build(:user)
          token = build(:external_api_access_token, external_service_name: 'orcid')
          user.external_api_access_tokens << token
          expect(user.access_token_for(external_service_name: 'orcid')).to eql(token)
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
