# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign up via email and password', type: :feature do
  include DmptoolHelper

  # TODO: implement this after we move to baseline homepage

  before(:each) do
    @existing = create(:user)
    @orgs = [create(:org), create(:org)]

    @first = Faker::Movies::StarWars.character.split.first
    @last = Faker::Movies::StarWars.character.split.last
    @email = Faker::Internet.unique.email
    @pwd = SecureRandom.uuid

    Rails.configuration.x.recaptcha.enabled = false

    # -------------------------------------------------------------
    # start DMPTool customization
    # Mock the blog feed on our homepage
    # -------------------------------------------------------------
    mock_blog
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

    visit root_path

    # -------------------------------------------------------------
    # start DMPTool customization
    # Access the sign in form
    # -------------------------------------------------------------
    # Action
    # click_link "Create account"
    #    access_create_account_modal
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------
  end
end
