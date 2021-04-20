# frozen_string_literal: true

class CustomFailure < Devise::FailureApp

  def redirect_url
    # Login failed! If we're in an Oauth workflow return to that workflow otherwise return to root
    session["oauth-referer"].present? ? session["oauth-referer"] : root_path
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

end
