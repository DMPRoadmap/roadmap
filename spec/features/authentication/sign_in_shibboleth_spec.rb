# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign in via email and password", type: :feature do

  include DmptoolHelper

  # TODO: implement this after we move to baseline homepage

  before(:each) do
    @pwd = SecureRandom.uuid
    @user = create(:user, password: @pwd, password_confirmation: @pwd)

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
    #click_link "Sign in"
#    access_sign_in_modal
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------
  end

end
