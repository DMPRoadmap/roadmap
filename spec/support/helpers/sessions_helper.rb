# frozen_string_literal: true

module SessionsHelper
  def sign_in(user = :user)
    case user
    when User
      sign_in_as_user(user)
    when Symbol
      sign_in_as_user(create(:user))
    else
      raise ArgumentError, "Invalid argument user: #{user}"
    end
  end

  def sign_in_as_user(user)
    clear_cookies!
    visit root_path

p "TRYING #{root_path} (#{root_url})"
p "HOST: #{ENV['HOST']}, SERVER_HOST: #{ENV["SERVER_HOST"]}"
# pp page.body

    within '#sign-in-form' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password.presence || 'password'
      click_button 'Sign in'
    end
  end
end
