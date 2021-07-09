# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign in via email and password", type: :feature do

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
  end

  scenario "User signs in with unknown email" do
    within("#sign_in_form") do
      fill_in "Email", with: Faker::Internet.unique.email
      fill_in "Password", with: @pwd
      click_button "Sign in"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Error: Invalid Email or password.")
  end

  scenario "User signs in with email and wrong password" do
    within("#sign_in_form") do
      fill_in "Email", with: @user.email
      fill_in "Password", with: "#{@pwd}p"
      click_button "Sign in"
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text("Error: Invalid Email or password.")
  end

  scenario "User signs in with their email and password" do
    within("#sign_in_form") do
      fill_in "Email", with: @user.email
      fill_in "Password", with: @pwd
      click_button "Sign in"
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text("My Dashboard")
  end

end
