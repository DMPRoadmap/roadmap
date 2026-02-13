# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'devise/registrations/_v2_api_token.html.erb' do
  let(:user) { create(:user) }
  let(:app_name) { Rails.application.config.x.application.internal_oauth_app_name }

  context 'when the OAuth application exists' do
    let!(:oauth_app) { create(:oauth_application, name: app_name) }

    it 'displays the regenerate button' do
      render partial: 'devise/registrations/v2_api_token', locals: { user: user }

      expect(rendered).to have_link('Regenerate token',
                                    href: api_v2_internal_user_access_token_path(format: :js))
    end

    context 'when user has a token' do
      let!(:token) do
        create(:oauth_access_token,
               application: oauth_app,
               resource_owner_id: user.id,
               scopes: 'read')
      end

      it 'displays the token' do
        render partial: 'devise/registrations/v2_api_token', locals: { user: user }

        expect(rendered).to have_selector('code', text: token.token)
        expect(rendered).not_to have_content('Click the button below to generate an API token')
      end
    end

    context 'when user does not have a token' do
      it 'displays the generate message' do
        render partial: 'devise/registrations/v2_api_token', locals: { user: user }

        expect(rendered).to have_content('Click the button below to generate an API token')
        expect(rendered).not_to have_selector('code')
      end
    end
  end

  context 'when the OAuth application does not exist' do
    it 'displays the warning message and helpdesk email link' do
      render partial: 'devise/registrations/v2_api_token', locals: { user: user }

      expect(rendered).to have_selector('.alert-warning')
      expect(rendered).to have_content('V2 API token service is currently unavailable')
      expect(rendered).to have_link(href: "mailto:#{Rails.application.config.x.organisation.helpdesk_email}")
    end

    it 'does not display the token or regenerate button' do
      render partial: 'devise/registrations/v2_api_token', locals: { user: user }

      expect(rendered).not_to have_link('Regenerate token')
      expect(rendered).not_to have_selector('code')
    end
  end
end
