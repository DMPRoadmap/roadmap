# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Devise 5 views', type: :request do
  it 'renders the password reset form with the supported error partial' do
    get edit_user_password_path, params: { reset_password_token: 'invalid' }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('user_reset_password_form')
  end

  it 'renders an invitation acceptance form with devise_invitable' do
    invited_user = User.invite!({ email: 'invited@example.org' }, create(:user))

    get accept_user_invitation_path, params: { invitation_token: invited_user.raw_invitation_token }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('invitation_create_account_form')
  end
end
