# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'devise/registrations/_v2_api_token.html.erb' do
  let(:user) { create(:user) }
  let(:app_name) { Rails.application.config.x.application.internal_oauth_app_name }

  def render_token_partial(token: nil)
    render partial: 'devise/registrations/v2_api_token', locals: { user: user, token: token }
  end

  context 'when the OAuth application exists' do
    let!(:oauth_app) { create(:oauth_application, name: app_name) }

    it 'displays the regenerate button when no token is present' do
      render_token_partial(token: nil)
      expect(rendered).to have_selector('button', text: 'Regenerate token')
    end

    context 'when user has a token' do
      let(:plaintext_token) { 'plaintext-token-value' }

      it 'displays the token and disables the regenerate button' do
        render_token_partial(token: plaintext_token)
        expect(rendered).to have_selector('#api-token-val')
        expect(rendered).not_to have_content('Click the button below to generate an API token')
        expect(rendered).to have_selector('button[disabled]', text: 'Regenerate token')
      end
    end

    context 'when user does not have a token' do
      it 'displays the generate message' do
        render_token_partial(token: nil)
        expect(rendered).to have_content('Click the button below to generate an API token')
        expect(rendered).not_to have_selector('#api-token-val')
      end
    end
  end

  context 'when the OAuth application does not exist' do
    it 'displays the warning message and helpdesk email link' do
      render_token_partial(token: nil)
      expect(rendered).to have_selector('.alert-warning')
      expect(rendered).to have_content('V2 API token service is currently unavailable')
      expect(rendered).to have_link(href: "mailto:#{Rails.application.config.x.organisation.helpdesk_email}")
    end

    it 'does not display the token or regenerate button' do
      render_token_partial(token: nil)
      expect(rendered).not_to have_selector('button', text: 'Regenerate token')
      expect(rendered).not_to have_selector('code')
    end
  end
end
