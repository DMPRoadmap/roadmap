# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign in via email and password', type: :feature do
  include Helpers::DmptoolHelper

  before(:each) do
    @pwd = SecureRandom.uuid
    @plan = create(:plan, :creator)
    @user = @plan.owner
    @user.update(password: @pwd, password_confirmation: @pwd)
    mock_blog
    visit root_path
    fill_in 'Email address', with: @user.email
    click_on 'Continue'
    expect(page).to have_text('Sign in')
  end

  scenario 'User signs in with email and wrong password' do
    within("form[action=\"#{user_session_path}\"]") do
      fill_in 'Password', with: "#{@pwd}p"
      click_button 'Sign in'
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text('Error: Invalid Email or password.')
  end

  scenario 'User signs in with their email and password' do
    within("form[action=\"#{user_session_path}\"]") do
      fill_in 'Password', with: @pwd
      click_button 'Sign in'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('My Dashboard')
  end
end
