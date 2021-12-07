# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request password reset', type: :feature do
  include DmptoolHelper

  before(:each) do
    @pwd = SecureRandom.uuid
    @plan = create(:plan, :creator)
    @user = @plan.owner
    @user.update(password: @pwd, password_confirmation: @pwd)

    # -------------------------------------------------------------
    # start DMPTool customization
    # Mock the blog feed on our homepage
    # -------------------------------------------------------------
    mock_blog
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

    visit root_path
    click_link 'Forgot password?'
  end

  scenario 'User enters an unknown email' do
    within('#user_request_reset_password_form') do
      fill_in 'Email', with: Faker::Internet.unique.email
      click_button 'Send'
    end

    expect(current_path).to eql(user_password_path)
    expect(page).to have_text('The email address you entered is not registered.')
  end

  scenario "User enters their email and clicks 'Send'" do
    expect(@user.reset_password_token.present?).to eql(false)
    expect(@user.reset_password_sent_at.present?).to eql(false)

    token = submit_reset_password_form_fetch_token

    expect(@user.reset_password_token.present?).to eql(true)
    expect(@user.reset_password_sent_at.present?).to eql(true)
    expect(token.present?).to eql(true)
  end

  scenario 'User resets their password via link in email' do
    token = submit_reset_password_form_fetch_token
    visit edit_user_password_path(reset_password_token: token)
    expect(page).to have_text('Change your password')

    pwd = SecureRandom.uuid
    fill_in 'New password', with: pwd
    fill_in 'Password confirmation', with: pwd
    click_button 'Save'

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Your password has been changed successfully. You are now signed in.')
  end

  scenario 'Invalid reset token ' do
    submit_reset_password_form_fetch_token

    visit edit_user_password_path(reset_password_token: Faker::Lorem.word)
    expect(page).to have_text('Change your password')

    pwd = SecureRandom.uuid
    fill_in 'New password', with: pwd
    fill_in 'Password confirmation', with: pwd
    click_button 'Save'

    expect(current_path).to eql(user_password_path)
    expect(page).to have_text('Reset password token is invalid')
  end

  scenario 'Invalid reset token ' do
    submit_reset_password_form_fetch_token

    visit edit_user_password_path(reset_password_token: Faker::Lorem.word)
    expect(page).to have_text('Change your password')

    pwd = SecureRandom.uuid
    fill_in 'New password', with: pwd
    fill_in 'Password confirmation', with: pwd
    click_button 'Save'

    expect(current_path).to eql(user_password_path)
    expect(page).to have_text('Reset password token is invalid')
  end

  # Helper method to submit the reset password form and return the reset token
  # rubocop:disable Metrics/AbcSize
  def submit_reset_password_form_fetch_token
    within('#user_request_reset_password_form') do
      fill_in 'Email', with: @user.email
      click_button 'Send'
    end

    @user = @user.reload
    expect(current_path).to eql(root_path)
    txt = 'You will receive an email with instructions on how to reset your password in a few minutes.'
    expect(page).to have_text(txt)

    email = ActionMailer::Base.deliveries.first
    expect(email.is_a?(Mail::Message)).to eql(true)
    expect(email.to).to eql([@user.email])
    expect(email.subject).to eql('Reset password instructions')

    email.body.to_s.match(/reset_password_token=[a-zA-Z0-9_]+/)
         .to_s.gsub('reset_password_token=', '')
  end
  # rubocop:enable Metrics/AbcSize
end
