# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'devise/registrations/_api_token.html.erb' do
  let(:app_name) { Rails.application.config.x.application.internal_oauth_app_name }
  let!(:oauth_app) { create(:oauth_application, name: app_name) }

  before do
    # Clear memoization between tests
    Api::V2::InternalUserAccessTokenService.instance_variable_set(:@application, nil)
  end

  context 'When a user has the `use_api` permission' do
    it 'renders both the v2 and legacy API token sections' do
      user = create(:user, :org_admin)

      render partial: 'devise/registrations/api_token', locals: { user: user }

      expect(rendered).to have_selector('#v2-api-token')
      expect(rendered).to have_selector('#legacy-api-token')
    end
  end

  context 'When a user does not have the `use_api` permission' do
    it 'renders only the v2 API token section' do
      user = create(:user)

      render partial: 'devise/registrations/api_token', locals: { user: user }

      expect(rendered).to have_selector('#v2-api-token')
      expect(rendered).not_to have_selector('#legacy-api-token')
    end
  end
end
