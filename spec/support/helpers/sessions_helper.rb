require_relative "dmptool_helper"

module SessionsHelper

  # -------------------------------------------------------------
  # start DMPTool customization
  # Switched so that we are stubbing/mocking User logins via the
  # Devise helper. We are already testing the Capybara login process
  # in the Sessions and Regsitrations tests. This should speed up
  # the tests a bit
  # -------------------------------------------------------------
  include DmptoolHelper

  def sign_in(user = :user)
    case user
    when User
      sign_in_as_user(user)
    when Symbol
      sign_in_as_user(create(:user, org: Org.find_by(is_other: true)))
    else
      raise ArgumentError, "Invalid argument user: #{user}"
    end
  end

  def sign_in_as_user(user)
    # Use the Devise helper to mock a successful user login
    login_as(user, :scope => :user)
    visit root_path
  end
  # -------------------------------------------------------------
  # end DMPTool customization
  # -------------------------------------------------------------

end
