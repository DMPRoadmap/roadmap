# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request password reset' do
  include Helpers::DmptoolHelper

  # Combining all of the tests into two because we have a rate limit set in rack_attack for this endpoint
  before do
    @pwd = SecureRandom.uuid
    @user = create(:user)
    mock_blog

    visit root_path
    fill_in 'Email address', with: @user.email
    click_on 'Continue'
    expect(page).to have_text('Sign in')
    click_link 'Forgot password?'
  end

  it 'User enters an unknown email' do
    within("form[action=\"#{user_password_path}\"]") do
      fill_in 'Email', with: 'foo@bar.edu'
      click_button 'Send'
    end

    expect(current_path).to eql(new_user_password_path)
    expect(page).to have_text('No account associated with that email address.')
  end

  it "User enters their email and clicks 'Send'" do
    expect(@user.reset_password_token.present?).to be(false)
    expect(@user.reset_password_sent_at.present?).to be(false)

    token = submit_reset_password_form_fetch_token

    expect(@user.reset_password_token.present?).to be(true)
    expect(@user.reset_password_sent_at.present?).to be(true)
    expect(token.present?).to be(true)
  end

  it 'User resets their password via link in email' do
    token = submit_reset_password_form_fetch_token
    visit edit_user_password_path(reset_password_token: token)
    expect(page).to have_text('Change your password')

    fill_in 'New password', with: @pwd
    fill_in 'Confirm new password', with: @pwd
    click_button 'Change my password'

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Your password has been changed successfully. You are now signed in.')
  end

  it 'Password mismatch' do
    token = submit_reset_password_form_fetch_token
    visit edit_user_password_path(reset_password_token: token)
    expect(page).to have_text('Change your password')

    fill_in 'New password', with: @pwd
    fill_in 'Confirm new password', with: SecureRandom.uuid
    click_button 'Change my password'

    expect(current_path).to eql(user_password_path)
    expect(page).to have_text('Password confirmation doesn\'t match Password')
  end

  it 'Invalid password' do
    token = submit_reset_password_form_fetch_token
    visit edit_user_password_path(reset_password_token: token)
    expect(page).to have_text('Change your password')

    fill_in 'New password', with: 'foo'
    fill_in 'Confirm new password', with: 'foo'
    click_button 'Change my password'

    expect(current_path).to eql(user_password_path)
    expect(page).to have_text('Password is too short')
  end

  # Helper method to submit the reset password form and return the reset token
  # rubocop:disable Metrics/AbcSize
  def submit_reset_password_form_fetch_token
    within("form[action=\"#{user_password_path}\"]") do
      fill_in 'Email', with: @user.email
      click_button 'Send'
    end

    @user = @user.reload
    expect(current_path).to eql(root_path)
    txt = 'You will receive an email with instructions on how to reset your password in a few minutes.'
    expect(page).to have_text(txt)

    email = ActionMailer::Base.deliveries.first
    expect(email.is_a?(Mail::Message)).to be(true)
    expect(email.to).to eql([@user.email])
    expect(email.subject).to eql('Reset password instructions')

    email.body.to_s.match(/reset_password_token=[a-zA-Z0-9_-]+/)
         .to_s.gsub('reset_password_token=', '')
  end
  # rubocop:enable Metrics/AbcSize
end
