# frozen_string_literal: true

# Override how Devise handles failures
class CustomFailure < Devise::FailureApp
  def redirect_url
    return root_path unless session['oauth-referer'].present?

    # If we're in an Oauth workflow return to that workflow otherwise return to root
    oauth_hash = ApplicationService.decrypt(payload: session['oauth-referer'])

    oauth_hash.present? && oauth_hash['path'].present? ? oauth_hash['path'] : root_path
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
